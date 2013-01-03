#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <json.h>
#include <printbuf.h>

#include <curl/curl.h>

#include <openssl/md5.h>

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
 *                 ||          pubnub_event_timeoutcb => pubnub.finished_cb
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


static void
pubnub_connection_finished(struct pubnub *p, CURLcode res)
{
	DBGMSG("DONE: (%d) %s\n", res, p->curl_error);

	/* Check against I/O errors */
	if (res != CURLE_OK) {
		if (res == CURLE_OPERATION_TIMEDOUT) {
			p->finished_cb(p, PNR_TIMEOUT, NULL, p->cb_data, p->finished_cb_data);
		} else {
			json_object *msgstr = json_object_new_string(curl_easy_strerror(res));
			p->finished_cb(p, PNR_IO_ERROR, msgstr, p->cb_data, p->finished_cb_data);
			json_object_put(msgstr);
		}
		return;
	}

	/* Check HTTP code */
	long code = 599;
	curl_easy_getinfo(p->curl, CURLINFO_RESPONSE_CODE, &code);
	if (code / 100 != 2) {
		json_object *httpcode = json_object_new_int(code);
		p->finished_cb(p, PNR_HTTP_ERROR, httpcode, p->cb_data, p->finished_cb_data);
		json_object_put(httpcode);
		return;
	}

	/* Parse body */
	json_object *response = json_tokener_parse(p->body->buf);
	if (!response) {
		p->finished_cb(p, PNR_FORMAT_ERROR, NULL, p->cb_data, p->finished_cb_data);
		return;
	}

	/* The regular callback */
	p->finished_cb(p, PNR_OK, response, p->cb_data, p->finished_cb_data);
	json_object_put(response);
}

static void
pubnub_connection_cleanup(struct pubnub *p, bool stop_wait)
{
	if (stop_wait)
		p->cb->stop_wait(p, p->cb_data);
	p->state = PNS_IDLE;

	curl_multi_remove_handle(p->curlm, p->curl);
	curl_easy_cleanup(p->curl);
	p->curl = NULL;
}

/* Let curl take care of the ongoing connections, then check for new events
 * and handle them (call the user callbacks etc.).  If stop_wait == true,
 * we have already called cb->wait and need to call cb->stop_wait if the
 * connection is over. Returns true if the connection has finished, otherwise
 * it is still running. */
static bool
pubnub_connection_check(struct pubnub *p, int fd, int bitmask, bool stop_wait)
{
	int running_handles = 0;
	CURLMcode rc = curl_multi_socket_action(p->curlm, fd, bitmask, &running_handles);
	DBGMSG("event_sockcb fd %d bitmask %d rc %d rh %d\n", fd, bitmask, rc, running_handles);
	if (rc != CURLM_OK) {
		json_object *msgstr = json_object_new_string(curl_multi_strerror(rc));
		p->finished_cb(p, PNR_IO_ERROR, msgstr, p->cb_data, p->finished_cb_data);
		json_object_put(msgstr);
		pubnub_connection_cleanup(p, stop_wait);
		return true;
	}

	CURLMsg *msg;
	int msgs_left;
	bool done = false;

	while ((msg = curl_multi_info_read(p->curlm, &msgs_left))) {
		if (msg->msg != CURLMSG_DONE)
			continue;

		/* Done! */
		pubnub_connection_finished(p, msg->data.result);
		pubnub_connection_cleanup(p, stop_wait);
		done = true;
	}

	return done;
}

/* Socket callback for pubnub_callbacks event notification. */
static void
pubnub_event_sockcb(struct pubnub *p, int fd, int mode, void *cb_data)
{
	int ev_bitmask =
		(mode & 1 ? CURL_CSELECT_IN : 0) |
		(mode & 2 ? CURL_CSELECT_OUT : 0) |
		(mode & 4 ? CURL_CSELECT_ERR : 0);

	pubnub_connection_check(p, fd, ev_bitmask, true);
}

static void
pubnub_event_timeoutcb(struct pubnub *p, void *cb_data)
{
	pubnub_connection_check(p, CURL_SOCKET_TIMEOUT, 0, true);
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

/* Timer callback for libcurl setting up a timeout notification. */
static int
pubnub_http_timercb(CURLM *multi, long timeout_ms, void *userp)
{
	struct pubnub *p = userp;

	DBGMSG("http_timercb: %ld ms\n", timeout_ms);

	struct timespec timeout_ts;
	if (timeout_ms > 0) {
		timeout_ts.tv_sec = timeout_ms/1000;
		timeout_ts.tv_nsec = (timeout_ms%1000)*1000000L;
		p->cb->timeout(p, p->cb_data, &timeout_ts, pubnub_event_timeoutcb, p);
	} else {
		if (timeout_ms == 0) {
			/* Timeout already reached. Call cb directly. */
			pubnub_event_timeoutcb(p, p);
		} /* else no timeout at all. */
		timeout_ts.tv_sec = 0;
		timeout_ts.tv_nsec = 0;
		p->cb->timeout(p, p->cb_data, &timeout_ts, NULL, NULL);
	}
	return 0;
}

struct pubnub *
pubnub_init(const char *publish_key, const char *subscribe_key,
		const char *secret_key, const char *cipher_key,
		const char *origin,
		const struct pubnub_callbacks *cb, void *cb_data)
{
	struct pubnub *p = calloc(1, sizeof(*p));
	if (!p) return NULL;

	p->publish_key = strdup(publish_key);
	p->subscribe_key = strdup(subscribe_key);
	if (!origin) origin = "pubsub.pubnub.com";
	p->origin = strdup(origin);
	p->secret_key = secret_key ? strdup(secret_key) : NULL;
	p->cipher_key = cipher_key ? strdup(cipher_key) : NULL;
	strcpy(p->time_token, "0");

	p->cb = cb;
	p->cb_data = cb_data;

	p->state = PNS_IDLE;
	p->body = printbuf_new();

	p->curlm = curl_multi_init();
	curl_multi_setopt(p->curlm, CURLMOPT_SOCKETFUNCTION, pubnub_http_sockcb);
	curl_multi_setopt(p->curlm, CURLMOPT_SOCKETDATA, p);
	curl_multi_setopt(p->curlm, CURLMOPT_TIMERFUNCTION, pubnub_http_timercb);
	curl_multi_setopt(p->curlm, CURLMOPT_TIMERDATA, p);

	p->curl_headers = curl_slist_append(p->curl_headers, "User-Agent: c-generic/0");
	p->curl_headers = curl_slist_append(p->curl_headers, "V: 3.4");

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
	curl_slist_free_all(p->curl_headers);

	printbuf_free(p->body);
	free(p->publish_key);
	free(p->subscribe_key);
	free(p->secret_key);
	free(p->cipher_key);
	free(p->origin);
	free(p);
}


static size_t
pubnub_http_inputcb(char *ptr, size_t size, size_t nmemb, void *userdata)
{
	struct pubnub *p = userdata;
	DBGMSG("http input: %zd bytes\n", size * nmemb);
	printbuf_memappend_fast(p->body, ptr, size * nmemb);
	return size * nmemb;
}

static void
pubnub_http_request(struct pubnub *p, const char *urlelems[],
		long timeout, pubnub_http_cb cb, void *cb_data)
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
	curl_easy_setopt(p->curl, CURLOPT_HTTPHEADER, p->curl_headers);
	curl_easy_setopt(p->curl, CURLOPT_WRITEFUNCTION, pubnub_http_inputcb);
	curl_easy_setopt(p->curl, CURLOPT_WRITEDATA, p);
	curl_easy_setopt(p->curl, CURLOPT_VERBOSE, VERBOSE_VAL);
	curl_easy_setopt(p->curl, CURLOPT_ERRORBUFFER, p->curl_error);
	curl_easy_setopt(p->curl, CURLOPT_PRIVATE, p);
	curl_easy_setopt(p->curl, CURLOPT_NOPROGRESS, 1L);
	curl_easy_setopt(p->curl, CURLOPT_NOSIGNAL, 1L);
	curl_easy_setopt(p->curl, CURLOPT_TIMEOUT, timeout);

	printbuf_reset(p->body);
	p->finished_cb = cb;
	p->finished_cb_data = cb_data;

	DBGMSG("add handle: pre\n");
	curl_multi_add_handle(p->curlm, p->curl);
	DBGMSG("add handle: post\n");

	if (!pubnub_connection_check(p, CURL_SOCKET_TIMEOUT, 0, false)) {
		/* Connection did not fail early, let's call wait and return. */
		DBGMSG("wait: pre\n");
		p->cb->wait(p, p->cb_data);
		DBGMSG("wait: post\n");
	}

	printbuf_free(url);
}


void
pubnub_publish(struct pubnub *p, const char *channel, struct json_object *message,
		long timeout, pubnub_publish_cb cb, void *cb_data)
{
	if (!cb) cb = p->cb->publish;

	if (p->state == PNS_BUSY) {
		if (cb)
			cb(p, PNR_OCCUPIED, NULL, p->cb_data, cb_data);
		return;
	}
	p->state = PNS_BUSY;

	const char *message_str = json_object_to_json_string(message);

	char *signature;
	if (p->secret_key) {
		MD5_CTX md5;
		MD5_Init(&md5);
		MD5_Update(&md5, p->publish_key, strlen(p->publish_key));
		MD5_Update(&md5, "/", 1);
		MD5_Update(&md5, p->subscribe_key, strlen(p->subscribe_key));
		MD5_Update(&md5, "/", 1);
		MD5_Update(&md5, p->secret_key, strlen(p->secret_key));
		MD5_Update(&md5, "/", 1);
		MD5_Update(&md5, channel, strlen(channel));
		MD5_Update(&md5, "/", 1);
		MD5_Update(&md5, message_str, strlen(message_str));
		MD5_Update(&md5, "" /* \0 */, 1);

		unsigned char digest[16];
		MD5_Final(digest, &md5);

		signature = malloc(33);
		for (int i = 0; i < 16; i++) {
			snprintf(&signature[i * 2], 3, "%02x", digest[i]);
		}
		/* The snprintf() in the last iteration implicitly
		 * NUL-terminates signature[]. */
	} else {
		signature = strdup("0");
	}

	const char *urlelems[] = { "publish", p->publish_key, p->subscribe_key, signature, channel, "0", message_str, NULL };
	pubnub_http_request(p, urlelems, timeout, (pubnub_http_cb) cb, cb_data);
	free(signature);
}


struct pubnub_subscribe_http_cb {
	char *channelset;
	pubnub_subscribe_cb cb;
	void *call_data;
};

static void
pubnub_subscribe_http_cb(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data)
{
	struct pubnub_subscribe_http_cb *cb_http_data = call_data;
	char *channelset = cb_http_data->channelset;
	call_data = cb_http_data->call_data;
	pubnub_subscribe_cb cb = cb_http_data->cb;
	free(cb_http_data);

	if (result != PNR_OK) {
error:
		cb(p, result, NULL, response, ctx_data, call_data);
		free(channelset);
		return;
	}

	/* Response must be an array, and its first element also an array. */
	if (!json_object_is_type(response, json_type_array)) {
		result = PNR_FORMAT_ERROR;
		goto error;
	}
	json_object *msg = json_object_array_get_idx(response, 0);
	if (!json_object_is_type(msg, json_type_array)) {
		result = PNR_FORMAT_ERROR;
		goto error;
	}
	int msg_n = json_object_array_length(msg);

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
	json_object *channelset_json = json_object_array_get_idx(response, 2);
	char **channels = malloc((msg_n + 1) * sizeof(channels[0]));
	if (channelset_json) {
		if (!json_object_is_type(channelset_json, json_type_string)) {
			result = PNR_FORMAT_ERROR;
			goto error;
		}
		free(channelset);
		channelset = strdup(json_object_get_string(channelset_json));

		/* Comma-split the channelset to channels[] array. */
		char *channelsetp = channelset, *channelsettok = NULL;
		for (int i = 0; i < msg_n; channelsetp = NULL, i++) {
			char *channelset1 = strtok_r(channelsetp, ",", &channelsettok);
			if (!channelset1) {
				for (; i < msg_n; i++) {
					/* Fill the rest of the array with
					 * empty strings. */
					channels[i] = strdup("");
				}
				break;
			}
			channels[i] = strdup(channelset1);
		}
	} else {
		for (int i = 0; i < msg_n; i++) {
			channels[i] = strdup(channelset);
		}
	}
	channels[msg_n] = NULL;
	free(channelset);

	/* Finally call the user callback. */
	cb(p, result, channels, json_object_array_get_idx(response, 0), ctx_data, call_data);
}

void
pubnub_subscribe(struct pubnub *p, const char *channel,
		long timeout, pubnub_subscribe_cb cb, void *cb_data)
{
	if (!cb) cb = p->cb->subscribe;

	if (p->state == PNS_BUSY) {
		if (cb)
			cb(p, PNR_OCCUPIED, NULL, NULL, p->cb_data, cb_data);
		return;
	}
	p->state = PNS_BUSY;

	struct pubnub_subscribe_http_cb *cb_http_data = malloc(sizeof(*cb_http_data));
	cb_http_data->channelset = strdup(channel);
	cb_http_data->cb = cb;
	cb_http_data->call_data = cb_data;

	const char *urlelems[] = { "subscribe", p->subscribe_key, channel, "0", p->time_token, NULL };
	pubnub_http_request(p, urlelems, timeout, pubnub_subscribe_http_cb, cb_http_data);
}

void
pubnub_subscribe_multi(struct pubnub *p, const char *channels[], int channels_n,
		long timeout, pubnub_subscribe_cb cb, void *cb_data)
{
	struct printbuf *channelset = printbuf_new();
	for (int i = 0; i < channels_n; i++) {
		printbuf_memappend_fast(channelset, channels[i], strlen(channels[i]));
		if (i < channels_n - 1)
			printbuf_memappend_fast(channelset, ",", 1);
		else
			printbuf_memappend_fast(channelset, "" /* \0 */, 1);
	}
	pubnub_subscribe(p, channelset->buf, timeout, cb, cb_data);
	printbuf_free(channelset);
}


void
pubnub_history(struct pubnub *p, const char *channel, int limit,
		long timeout, pubnub_history_cb cb, void *cb_data)
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
