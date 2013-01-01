#ifndef PUBNUB__PubNub_h
#define PUBNUB__PubNub_h

#include <json.h>

#ifdef __cplusplus
extern "C" {
#endif


/* struct pubnub is a PubNub context, holding the complete PubNub
 * library state, especially the credentials and a persistent HTTP
 * connection.  The structure should be treated as completely opaque
 * by the application.
 *
 * Only one method may operate on a single context at once - this means
 * that if a subscribe is in progress, you cannot publish in the same
 * context; either wait or use multiple contexts. If the same context
 * is used in multiple threads, the application must ensure locking to
 * prevent improper concurrent access. */
struct pubnub;


/* Result codes for PubNub methods. */
enum pubnub_res {
	/* Success. */
	PNR_OK,
	/* Another method already in progress. */
	PNR_OCCUPIED,
	/* Time out before the request has completed. */
	PNR_TIMEOUT,
	/* Communication error. response is string object with the error. */
	PNR_IO_ERROR,
	/* HTTP error. response contains number object with the status code. */
	PNR_HTTP_ERROR,
	/* Unexpected input in received JSON. */
	PNR_FORMAT_ERROR,
};

/* ctx_data is callbacks data passed to pubnub_init().
 * call_data is callbacks data passed to method call. */

/* Callback functions to user code upon completion of various methods. */
/* Note that if the function wants to preserve the response, it should
 * bump its reference count, otherwise it will be auto-released after
 * callback is done. channels[], on the other hand, are dynamically
 * allocated and both the array and its individual items must be free()d
 * by the callee; to ease iteration by user code, there is guaranteed to
 * be as many elements as there are messages in the channels list, and
 * an extra NULL pointer at the end of the array. */
typedef void (*pubnub_publish_cb)(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data);
typedef void (*pubnub_subscribe_cb)(struct pubnub *p, enum pubnub_res result, char **channels, struct json_object *response, void *ctx_data, void *call_data);
typedef void (*pubnub_history_cb)(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data);

/* struct pubnub_callbacks describes the way PubNub calls coordinate
 * with the rest of the application; they tell what happens on pubnub
 * methods calls, enabling the application to either use the API
 * synchronously, use a custom callback system or rely on an external
 * event loop (such as GTK's, libevent etc.). */
struct pubnub_callbacks {
	/* Functions for low-level event handling. */
	/* This is the main interface to event loop wrappers. */

	/* Watch for events on a given file descriptor.
	 * (mode & 1) means watching for input, (mode & 2) means
	 * watching for output (both bits can be set). In case
	 * mode needs to be changed, rem_socket() is called first,
	 * then add_socket() with new terms. cb(mode) has same
	 * bit assignments (to be set based on events), plus (mode & 4)
	 * for error event. */
	void (*add_socket)(struct pubnub *p, void *ctx_data, int fd, int mode,
			void (*cb)(struct pubnub *p, int fd, int mode, void *cb_data), void *cb_data);
	/* Stop watching given file descriptor. */
	void (*rem_socket)(struct pubnub *p, void *ctx_data, int fd);
	/* Declare that events should be awaited now.
	 * This is usually called at the end of the main method
	 * body and is expected to just register the timeout
	 * callback. However, synchronous interface may actually
	 * block until a stop_wait call here. */
	void (*wait)(struct pubnub *p, void *ctx_data, int timeout,
			void (*cb)(struct pubnub *p, void *cb_data), void *cb_data);
	/* Stop the registered timeout wait, declaring that all
	 * relevant events have been received and handled by now.
	 * This is usually called at the end of the final socket
	 * callback, maybe after unregistering socket events. */
	void (*stop_wait)(struct pubnub *p, void *ctx_data);
	/* Deinitialize. Called from pubnub_done(), should remove
	 * all event listeners associated with this context. */
	void (*done)(struct pubnub *p, void *ctx_data);

	/* Default method callbacks. */
	/* These are called on method finish if user passes NULL
	 * as the callback in a particular method call. */

	pubnub_publish_cb publish;
	pubnub_subscribe_cb subscribe;
	pubnub_history_cb history;
};


/* origin is optional */
/* curl_global_init() caveat */
struct pubnub *pubnub_init(const char *publish_key, const char *subscribe_key,
			const char *origin,
			const struct pubnub_callbacks *cb, void *cb_data);
void pubnub_done(struct pubnub *p);

void pubnub_publish(struct pubnub *p, const char *channel,
		struct json_object *message,
		int timeout, pubnub_publish_cb cb, void *cb_data);
void pubnub_subscribe(struct pubnub *p, const char *channel,
		int timeout, pubnub_subscribe_cb cb, void *cb_data);
void pubnub_subscribe_multi(struct pubnub *p, const char *channels[], int channels_n,
		int timeout, pubnub_subscribe_cb cb, void *cb_data);
void pubnub_history(struct pubnub *p, const char *channel, int limit,
		int timeout, pubnub_history_cb cb, void *cb_data);

#ifdef __cplusplus
}
#endif

#endif
