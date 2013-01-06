#ifndef PUBNUB__PubNub_priv_h
#define PUBNUB__PubNub_priv_h

#include <printbuf.h>
#include <curl/curl.h>

#include "pubnub.h"

struct json_object;

typedef void (*pubnub_http_cb)(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data);

struct pubnub {
	char *publish_key, *subscribe_key;
	char *secret_key, *cipher_key;
	char *origin;
	char time_token[64];

	const struct pubnub_callbacks *cb;
	void *cb_data;

	enum pubnub_state {
		PNS_IDLE, /* No method in progress. */
		PNS_BUSY, /* A method in progress. */
	} state;
	/* Callback information for the method currently
	 * in progress. Call this when we have received
	 * complete HTTP reply and the method should be
	 * completed. May be NULL in case of no notification
	 * required! */
	pubnub_http_cb finished_cb;
	void *finished_cb_data;

	CURL *curl;
	CURLM *curlm;
	struct curl_slist *curl_headers;
	char curl_error[CURL_ERROR_SIZE];
	struct printbuf *body;
};

#ifdef DEBUG
#define DBGMSG(x...) do { fprintf(stderr, "[%d] ", __LINE__); printf(x); } while (0)
#define VERBOSE_VAL 1L
#else
#define DBGMSG(x...) do { } while (0)
#define VERBOSE_VAL 0L
#endif

#endif
