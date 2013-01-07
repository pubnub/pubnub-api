#include <errno.h>
#include <poll.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "pubnub.h"
#include "pubnub-priv.h"
#include "pubnub-sync.h"


/** Data structures. */

struct pubnub_cb_info {
	void (*cb)(struct pubnub *p, int fd, int mode, void *cb_data);
	void *cb_data;
};

struct pubnub_sync {
	int n;
	struct pollfd *fdset;
	struct pubnub_cb_info *cbset;

	struct timespec timeout_at;
	void (*timeout_cb)(struct pubnub *p, void *cb_data);
	void *timeout_cb_data;

	bool stop;

	/* */
	enum pubnub_res result;
	/* Response object pertaining to the last method
	 * executed. Refcounted. */
	struct json_object *response;
	/* Channel information from the last subscribe. */
	char **channels;
};

static void
pubnub_sync_reset(struct pubnub_sync *sync)
{
	if (sync->response) {
		json_object_put(sync->response);
		sync->response = NULL;
	}
	if (sync->channels) {
		for (int i = 0; sync->channels[i]; i++)
			free(sync->channels[i]);
		free(sync->channels);
		sync->channels = NULL;
	}
}


/** Public API */

PUBNUB_API
struct pubnub_sync *
pubnub_sync_init(void)
{
	struct pubnub_sync *sync = calloc(1, sizeof(*sync));
	/* We should make sure this is not PNR_OK by default
	 * and PNR_OCCUPIED should never happen in our usage. */
	sync->result = PNR_OCCUPIED;
	return sync;
}

PUBNUB_API
enum pubnub_res
pubnub_sync_last_result(struct pubnub_sync *sync)
{
	return sync->result;
}

PUBNUB_API
struct json_object *
pubnub_sync_last_response(struct pubnub_sync *sync)
{
	return sync->response ? json_object_get(sync->response) : NULL;
}

PUBNUB_API
char **
pubnub_sync_last_channels(struct pubnub_sync *sync)
{
	return sync->channels;
}


/** Event callbacks */

void
pubnub_sync_add_socket(struct pubnub *p, void *ctx_data, int fd, int mode,
		void (*cb)(struct pubnub *p, int fd, int mode, void *cb_data), void *cb_data)
{
	DBGMSG("+ socket %d\n", fd);

	struct pubnub_sync *sync = ctx_data;
	int i = sync->n++;

	sync->fdset = realloc(sync->fdset, sizeof(*sync->fdset) * sync->n);
	sync->fdset[i].fd = fd;
	sync->fdset[i].events = (mode & 1 ? POLLIN : 0) | (mode & 2 ? POLLOUT : 0);

	sync->cbset = realloc(sync->cbset, sizeof(*sync->cbset) * sync->n);
	sync->cbset[i].cb = cb;
	sync->cbset[i].cb_data = cb_data;

	DBGMSG("watching %d sockets\n", sync->n);
}

void
pubnub_sync_rem_socket(struct pubnub *p, void *ctx_data, int fd)
{
	DBGMSG("- socket %d\n", fd);
	struct pubnub_sync *sync = ctx_data;

	for (int i = 0; i < sync->n; i++) {
		if (sync->fdset[i].fd != fd)
			continue;
		memmove(&sync->fdset[i], &sync->fdset[i + 1], (sync->n - i - 1) * sizeof(*sync->fdset));
		memmove(&sync->cbset[i], &sync->cbset[i + 1], (sync->n - i - 1) * sizeof(*sync->cbset));
		sync->n--;
		return;
	}
	DBGMSG("! did not find socket %d\n", fd);
}

void
pubnub_sync_timeout(struct pubnub *p, void *ctx_data, const struct timespec *ts,
		void (*cb)(struct pubnub *p, void *cb_data), void *cb_data)
{
	struct pubnub_sync *sync = ctx_data;
	sync->timeout_cb = cb;
	sync->timeout_cb_data = cb_data;

	if (sync->timeout_cb) {
		struct timespec now;
		clock_gettime(CLOCK_REALTIME, &now);
		sync->timeout_at.tv_sec = now.tv_sec + ts->tv_sec;
		sync->timeout_at.tv_nsec = now.tv_nsec + ts->tv_nsec;
		if (sync->timeout_at.tv_nsec > 1000000000L) {
			sync->timeout_at.tv_sec++;
			sync->timeout_at.tv_nsec -= 1000000000L;
		}
		DBGMSG("timeout set to %ld . %ld\n", sync->timeout_at.tv_sec, sync->timeout_at.tv_nsec);
	}
}

void
pubnub_sync_wait(struct pubnub *p, void *ctx_data)
{
	struct pubnub_sync *sync = ctx_data;
	while (!sync->stop) {
		DBGMSG("=polling= for %d (timeout %p)\n", sync->n, sync->timeout_cb);

		long timeout;
		if (sync->timeout_cb) {
			struct timespec now;
			clock_gettime(CLOCK_REALTIME, &now);
			timeout = (sync->timeout_at.tv_sec - now.tv_sec) * 1000;
			timeout += (sync->timeout_at.tv_nsec - now.tv_nsec) / 1000000;
			DBGMSG("timeout in %ld ms\n", timeout);
			if (timeout < 0) {
				/* If we missed the timeout moment, just
				 * spin poll() quickly until we are clear
				 * to call the timeout handler. */
				timeout = 0;
			}
		} else {
			timeout = -1;
		}

		int n = poll(sync->fdset, sync->n, timeout);

		if (n < 0) {
			/* poll() errors are ignored, it's not clear what
			 * we should do. Most likely, we have just received
			 * a signal and will spin around and restart poll(). */
			DBGMSG("poll(): %s\n", strerror(errno));
			continue;
		}

		if (n == 0) {
			/* Time out, call the handler and reset
			 * timeout. */
			DBGMSG("Timeout, callback and reset\n");
			/* First, we reset sync->timeout_cb, then we
			 * call the timeout handler - likely, that will
			 * cause it to set timeout_cb again, so resetting
			 * timeout_cb only after the call is bad idea. */
			void (*timeout_cb)(struct pubnub *p, void *cb_data) = sync->timeout_cb;
			sync->timeout_cb = NULL;
			timeout_cb(p, sync->timeout_cb_data);
			continue;
		}

		for (int i = 0; i < sync->n; i++) {
			short revents = sync->fdset[i].revents;
			if (!revents)
				continue;
			DBGMSG("event: fd %d ev %d rev %d\n", sync->fdset[i].fd, sync->fdset[i].events, sync->fdset[i].revents);
			int mode = (revents & POLLIN ? 1 : 0) | (revents & POLLOUT ? 2 : 0) | (revents & POLLERR ? 4 : 0);
			sync->cbset[i].cb(p, sync->fdset[i].fd, mode, sync->cbset[i].cb_data);
		}
	}
	sync->stop = false;
}

void
pubnub_sync_stop_wait(struct pubnub *p, void *ctx_data)
{
	struct pubnub_sync *sync = ctx_data;
	sync->stop = true;
	sync->timeout_cb = NULL;
}

void
pubnub_sync_done(struct pubnub *p, void *ctx_data)
{
	struct pubnub_sync *sync = ctx_data;
	pubnub_sync_reset(sync);
	if (sync->fdset) free(sync->fdset);
	if (sync->cbset) free(sync->cbset);
	free(sync);
}


/** Method callbacks */

void
pubnub_sync_generic_cb(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data)
{
	struct pubnub_sync *sync = ctx_data;

	pubnub_sync_reset(sync);

	sync->result = result;
	if (response)
		sync->response = json_object_get(response);
}

void
pubnub_sync_subscribe_cb(struct pubnub *p, enum pubnub_res result, char **channels, struct json_object *response, void *ctx_data, void *call_data)
{
	struct pubnub_sync *sync = ctx_data;
	pubnub_sync_generic_cb(p, result, response, ctx_data, call_data);
	if (result == PNR_OK) {
		sync->channels = channels;
	}
}


/** Callback table */

PUBNUB_API
struct pubnub_callbacks pubnub_sync_callbacks = {
	.add_socket = pubnub_sync_add_socket,
	.rem_socket = pubnub_sync_rem_socket,
	.timeout = pubnub_sync_timeout,
	.wait = pubnub_sync_wait,
	.stop_wait = pubnub_sync_stop_wait,
	.done = pubnub_sync_done,

	.publish = pubnub_sync_generic_cb,
	.subscribe = pubnub_sync_subscribe_cb,
	.history = pubnub_sync_generic_cb,
};
