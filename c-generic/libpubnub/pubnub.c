#include <stdlib.h>
#include <string.h>

#include <json.h>
#include <printbuf.h>

#include <curl/curl.h>

#include "pubnub.h"
#include "pubnub-priv.h"

/* TODO: Use curl shares. */

/* Due to all the callbacks for async safety, things may appear a bit tangled.
 * This diagram might help:
 *
 * pubnub_{publish,subscribe,history}
 *                 ||
 *                 vv
 *        pubnub_http_request => [pubnub_callbacks]
 *                 ||                   |
 *                 ||                   v
 *                 ||          pubnub_timeout_cb => pubnub.finished_cb
 *                 ||
 *             [libcurl] (we ask libcurl to issue the request)
 *                  |
 *                  v
 *         pubnub_http_sockcb (libcurl is interested in some socket events)
 *                 ||
 *          [pubnub_callbacks] (user code polls for socket events)
 *                  |
 *                  v
 *         pubnub_event_sockcb => [libcurl] (we notify curl about socket event)
 *                 ||                 ||
 *                 ||         pubnub_http_inputcb (new data arrived;
 *                 ||                              accumulated in pubnub.body)
 *                 ||
 *           pubnub.finished_cb (possibly, the request got completed)
 *
 * pubnub.finished_cb is the user-provided parameter
 * to pubnub_{publish,history} or a custom channel-parsing wrapper
 * around user-provided parameter to pubnub_subscribe()
 *
 * double lines (=, ||) are synchronous calls,
 * single lines (-, |) are asynchronous callbacks */

/* This is complex stuff, so let's provide yet another viewpoint,
 * a possible timeline (| denotes a sort of "context"):
 *
 * pubnub_publish
 *  pubnub_http_request
 *   curl_multi_add_handle
 *    pubnub_http_sockcb
 *     cb.add_socket    ---.
 *   cb.wait            ---+--.
 * <user's event loop>     |  |
 * pubnub_event_sockcb  ---'  |
 *  finished_cb               |
 *  cb.stop_wait        ------' (if not called in time,
 *                               wait triggers pubnub_timeout_cb)
 */


/* Socket callback for pubnub_callbacks event notification. */
static void
pubnub_event_sockcb(struct pubnub *p, int fd, int mode, void *cb_data)
{
	int ev_bitmask =
		(mode & 1 ? CURL_CSELECT_IN : 0) |
		(mode & 2 ? CURL_CSELECT_OUT : 0) |
		(mode & 4 ? CURL_CSELECT_ERR : 0);

	int running_handles = 0;
	CURLMcode rc = curl_multi_socket_action(p->curlm, fd, ev_bitmask, &running_handles);
	DBGMSG("event_sockcb fd %d mode %d rc %d rh %d\n", fd, mode, rc, running_handles);
	(void) rc;

	/* TODO rc error handling */
#if 0
		if (!p->curl) { /* TODO */
			/* Let's blindly hope errno is instructive. */
			json_object *jerrno = json_object_new_int(errno);
			cb(p, PNR_IO_ERROR, jerrno, p->ctx_data, cb_data);
			json_object_put(jerrno);
			printbuf_free(url);
			return;
		}
#endif

	CURLMsg *msg;
	int msgs_left;

	while ((msg = curl_multi_info_read(p->curlm, &msgs_left))) {
		if (msg->msg != CURLMSG_DONE)
			continue;

		/* Done! */
		CURLcode res = msg->data.result;
		DBGMSG("DONE: (%d) %s\n", res, p->curl_error);
		(void) res;
		/* FIXME: res test */

		/* Parse */
		json_object *response = json_tokener_parse(p->body->buf);
		if (response) {
			p->finished_cb(p, PNR_OK, response, p->cb_data, p->finished_cb_data);
			json_object_put(response);
		} else {
			p->finished_cb(p, PNR_FORMAT_ERROR, NULL, p->cb_data, p->finished_cb_data);
		}
		p->cb->stop_wait(p, p->cb_data);
		p->state = PNS_IDLE;

		curl_multi_remove_handle(p->curlm, p->curl);
		curl_easy_cleanup(p->curl);
		p->curl = NULL;
	}
}

/* Socket callback for libcurl setting up / tearing down watches. */
static int
pubnub_http_sockcb(CURL *easy, curl_socket_t s, int action, void *userp, void *socketp)
{
	struct pubnub *p = userp;

	DBGMSG("http_sockcb: fd %d action %d sockdata %p\n", s, action, socketp);

	if (action == CURL_POLL_REMOVE) {
		p->cb->rem_socket(p, p->cb_data, s);

	} else if (action == CURL_POLL_NONE) {
		/* Nothing to do? */

	} else {
		/* We use the socketp pointer just as a marker of whether
		 * we have already been called on this socket (i.e. should
		 * issue rem_socket() first). The particular value does
		 * not matter, as long as it's not NULL. */
		if (socketp)
			p->cb->rem_socket(p, p->cb_data, s);
		curl_multi_assign(p->curlm, s, /* anything not NULL */ easy);
		/* add_socket()'s mode uses the same bit pattern as
		 * libcurl's action. What a coincidence! ;-) */
		p->cb->add_socket(p, p->cb_data, s, action, pubnub_event_sockcb, easy);
	}
	return 0;
}

struct pubnub *
pubnub_init(const char *publish_key, const char *subscribe_key, const char *origin,
		const struct pubnub_callbacks *cb, void *cb_data)
{
	struct pubnub *p = calloc(1, sizeof(*p));
	if (!p) return NULL;

	p->publish_key = strdup(publish_key);
	p->subscribe_key = strdup(subscribe_key);
	if (!origin) origin = "pubsub.pubnub.com";
	p->origin = strdup(origin);
	strcpy(p->time_token, "0");

	p->cb = cb;
	p->cb_data = cb_data;

	p->state = PNS_IDLE;
	p->body = printbuf_new();

	p->curlm = curl_multi_init();
	curl_multi_setopt(p->curlm, CURLMOPT_SOCKETFUNCTION, pubnub_http_sockcb);
	curl_multi_setopt(p->curlm, CURLMOPT_SOCKETDATA, p);
	//curl_multi_setopt(p->curlm, CURLMOPT_TIMERFUNCTION, multi_timer_cb);
	//curl_multi_setopt(p->curlm, CURLMOPT_TIMERDATA, &g);

	return p;
}

void
pubnub_done(struct pubnub *p)
{
	if (p->cb->done)
		p->cb->done(p, p->cb_data);

	if (p->curl) {
		curl_multi_remove_handle(p->curlm, p->curl);
		curl_easy_cleanup(p->curl);
	}
	curl_multi_cleanup(p->curlm);

	printbuf_free(p->body);
	free(p->publish_key);
	free(p->subscribe_key);
	free(p->origin);
	free(p);
}


static size_t
pubnub_http_input_cb(char *ptr, size_t size, size_t nmemb, void *userdata)
{
	struct pubnub *p = userdata;
	DBGMSG("http input: %zd bytes\n", size * nmemb);
	printbuf_memappend_fast(p->body, ptr, size * nmemb);
	return size * nmemb;
}

static void
pubnub_timeout_cb(struct pubnub *p, void *cb_data)
{
	if (p->finished_cb)
		p->finished_cb(p, PNR_TIMEOUT, NULL, p->cb_data, p->finished_cb_data);
	p->cb->stop_wait(p, p->cb_data);
	p->state = PNS_IDLE;
}

static void
pubnub_http_request(struct pubnub *p, const char *urlelems[],
		int timeout, pubnub_http_cb cb, void *cb_data)
{
	p->curl = curl_easy_init();

	struct printbuf *url = printbuf_new();
	printbuf_memappend_fast(url, "http://", 7);
	printbuf_memappend_fast(url, p->origin, strlen(p->origin));
	for (const char **urlelemp = urlelems; *urlelemp; urlelemp++) {
		printbuf_memappend_fast(url, "/", 1);
		char *urlenc = curl_easy_escape(p->curl, *urlelemp, strlen(*urlelemp));
		printbuf_memappend_fast(url, urlenc, strlen(urlenc));
		curl_free(urlenc);
	}
	printbuf_memappend_fast(url, "" /* \0 */, 1);

	curl_easy_setopt(p->curl, CURLOPT_URL, url->buf);
	curl_easy_setopt(p->curl, CURLOPT_WRITEFUNCTION, pubnub_http_input_cb);
	curl_easy_setopt(p->curl, CURLOPT_WRITEDATA, p);
	curl_easy_setopt(p->curl, CURLOPT_VERBOSE, VERBOSE_VAL);
	curl_easy_setopt(p->curl, CURLOPT_ERRORBUFFER, p->curl_error);
	curl_easy_setopt(p->curl, CURLOPT_PRIVATE, p);
	curl_easy_setopt(p->curl, CURLOPT_NOPROGRESS, 1L);
	/* TODO timeout; also support in multi */

	printbuf_reset(p->body);
	p->finished_cb = cb;
	p->finished_cb_data = cb_data;

	DBGMSG("add handle: pre\n");
	curl_multi_add_handle(p->curlm, p->curl);
	DBGMSG("add handle: post\n");

	int i = 0;
	curl_multi_socket_action(p->curlm, CURL_SOCKET_TIMEOUT, 0, &i);

	DBGMSG("wait: pre\n");
	p->cb->wait(p, p->cb_data, timeout, pubnub_timeout_cb, NULL);
	DBGMSG("wait: post\n");

	printbuf_free(url);
}


void
pubnub_publish(struct pubnub *p, const char *channel, struct json_object *message,
		int timeout, pubnub_publish_cb cb, void *cb_data)
{
	if (!cb) cb = p->cb->publish;

	if (p->state == PNS_BUSY) {
		if (cb)
			cb(p, PNR_OCCUPIED, NULL, p->cb_data, cb_data);
		return;
	}
	p->state = PNS_BUSY;

	const char *urlelems[] = { "publish", p->publish_key, p->subscribe_key, "0" /* TODO SSL support */, channel, "0", json_object_to_json_string(message), NULL };
	pubnub_http_request(p, urlelems, timeout, (pubnub_http_cb) cb, cb_data);
}


struct pubnub_subscribe_http_cb {
	char *channel;
	pubnub_subscribe_cb cb;
	void *call_data;
};

static void
pubnub_subscribe_http_cb(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data)
{
	struct pubnub_subscribe_http_cb *cb_http_data = call_data;
	char *channel = cb_http_data->channel;
	call_data = cb_http_data->call_data;
	pubnub_subscribe_cb cb = cb_http_data->cb;
	free(cb_http_data);

	if (result != PNR_OK) {
error:
		cb(p, result, channel, response, ctx_data, call_data);
		free(channel);
		return;
	}

	/* Response must be an array. */
	if (!json_object_is_type(response, json_type_array)) {
		result = PNR_FORMAT_ERROR;
		goto error;
	}

	/* Extract and save time token (mandatory). */
	json_object *time_token = json_object_array_get_idx(response, 1);
	if (!time_token || !json_object_is_type(time_token, json_type_string)) {
		result = PNR_FORMAT_ERROR;
		goto error;
	}
	strncpy(p->time_token, json_object_get_string(time_token), sizeof(p->time_token));
	p->time_token[sizeof(p->time_token) - 1] = 0;

	/* Extract and update channel name (not mandatory, present only
	 * when multiplexing). */
	json_object *channel_name = json_object_array_get_idx(response, 2);
	if (channel_name) {
		if (!json_object_is_type(channel_name, json_type_string)) {
			result = PNR_FORMAT_ERROR;
			goto error;
		}
		free(channel);
		channel = strdup(json_object_get_string(channel_name));
	}

	/* Finally call the user callback. */
	cb(p, result, channel, json_object_array_get_idx(response, 1), ctx_data, call_data);
	free(channel);
}

void
pubnub_subscribe(struct pubnub *p, const char *channel,
		int timeout, pubnub_subscribe_cb cb, void *cb_data)
{
	if (!cb) cb = p->cb->subscribe;

	if (p->state == PNS_BUSY) {
		if (cb)
			cb(p, PNR_OCCUPIED, channel, NULL, p->cb_data, cb_data);
		return;
	}
	p->state = PNS_BUSY;

	struct pubnub_subscribe_http_cb *cb_http_data = malloc(sizeof(*cb_http_data));
	cb_http_data->channel = strdup(channel);
	cb_http_data->cb = cb;
	cb_http_data->call_data = cb_data;

	const char *urlelems[] = { "subscribe", p->subscribe_key, channel, "0", p->time_token, NULL };
	pubnub_http_request(p, urlelems, timeout, pubnub_subscribe_http_cb, cb_http_data);
}

void
pubnub_subscribe_multi(struct pubnub *p, const char *channels[], int channels_n,
		int timeout, pubnub_subscribe_cb cb, void *cb_data)
{
	struct printbuf *channel = printbuf_new();
	for (int i = 0; i < channels_n; i++) {
		printbuf_memappend_fast(channel, channels[i], strlen(channels[i]));
		if (i < channels_n - 1)
			printbuf_memappend_fast(channel, ",", 1);
		else
			printbuf_memappend_fast(channel, "" /* \0 */, 1);
	}
	pubnub_subscribe(p, channel->buf, timeout, cb, cb_data);
	printbuf_free(channel);
}


void
pubnub_history(struct pubnub *p, const char *channel, int limit,
		int timeout, pubnub_history_cb cb, void *cb_data)
{
	if (!cb) cb = p->cb->history;

	if (p->state == PNS_BUSY) {
		if (cb)
			cb(p, PNR_OCCUPIED, NULL, p->cb_data, cb_data);
		return;
	}
	p->state = PNS_BUSY;

	char strlimit[64]; snprintf(strlimit, sizeof(strlimit), "%d", limit);
	const char *urlelems[] = { "history", p->subscribe_key, channel, "0", strlimit, NULL };
	pubnub_http_request(p, urlelems, timeout, (pubnub_http_cb) cb, cb_data);
}
