#include <poll.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "pubnub.h"
#include "pubnub-priv.h"


/** Data structures. */

struct pubnub_cb_info {
	void (*cb)(struct pubnub *p, int fd, int mode, void *cb_data);
	void *cb_data;
};

struct pubnub_sync {
	int n;
	struct pollfd *fdset;
	struct pubnub_cb_info *cbset;

	bool stop;

	/* */
	enum pubnub_res result;
	/* Response object pertaining to the last method
	 * executed. Refcounted. */
	struct json_object *response;
	/* Channel information from the last subscribe. */
	char **channels;
};


/** Public API */

struct pubnub_sync *
pubnub_sync_init(void)
{
	struct pubnub_sync *sync = calloc(1, sizeof(*sync));
	/* We should make sure this is not PNR_OK by default
	 * and PNR_OCCUPIED should never happen in our usage. */
	sync->result = PNR_OCCUPIED;
	return sync;
}

enum pubnub_res
pubnub_sync_last_result(struct pubnub_sync *sync)
{
	return sync->result;
}

struct json_object *
pubnub_sync_last_response(struct pubnub_sync *sync)
{
	return sync->response ? json_object_get(sync->response) : NULL;
}

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

void pubnub_sync_wait(struct pubnub *p, void *ctx_data, int timeout,
		void (*cb)(struct pubnub *p, void *cb_data), void *cb_data)
{
	struct pubnub_sync *sync = ctx_data;
	while (!sync->stop) {
		/* TODO timeout */
		DBGMSG("=polling= for %d\n", sync->n);
		/* TODO poll() error handling? */
		poll(sync->fdset, sync->n, -1);
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
}

void
pubnub_sync_done(struct pubnub *p, void *ctx_data)
{
	struct pubnub_sync *sync = ctx_data;
	if (sync->fdset) free(sync->fdset);
	if (sync->cbset) free(sync->cbset);
	free(sync);
}


/** Method callbacks */

void
pubnub_sync_generic_cb(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data)
{
	struct pubnub_sync *sync = ctx_data;

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

	sync->result = result;
	if (result == PNR_OK)
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

struct pubnub_callbacks pubnub_sync_callbacks = {
	.add_socket = pubnub_sync_add_socket,
	.rem_socket = pubnub_sync_rem_socket,
	.wait = pubnub_sync_wait,
	.stop_wait = pubnub_sync_stop_wait,
	.done = pubnub_sync_done,

	.publish = pubnub_sync_generic_cb,
	.subscribe = pubnub_sync_subscribe_cb,
	.history = pubnub_sync_generic_cb,
};
