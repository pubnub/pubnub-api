#ifndef PUBNUB__PubNub_sync_h
#define PUBNUB__PubNub_sync_h

#include <pubnub.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque objects. */
struct pubnub_sync;
struct json_object;

/* Callback structure to pass pubnub_init(). */
extern struct pubnub_callbacks pubnub_sync_callbacks;

/* Callback data to pass pubnub_init(). */
struct pubnub_sync *pubnub_sync_init(void);

/* Return result of the last issued method. Always check whether
 * this is PNR_OK before issuing pubnub_sync_last_response(). */
enum pubnub_res pubnub_sync_last_result(struct pubnub_sync *sync);

/* Return JSON object the server response from the last PubNub method
 * call issued. json_object_get() is automatically called on it,
 * therefore you must call json_object_put() when you are going to drop
 * the reference to the object. */
/* The object is an array of messages; use standard json accessors
 * to access the individual messages. The array may also be empty
 * if no new messages arrived for some time (and in case of the first
 * call). */
struct json_object *pubnub_sync_last_response(struct pubnub_sync *sync);

/* Return names of the channels carrying the messages returned by the last
 * subscribe method call. The subscribe call returns array of messages,
 * corresponding items in this array are the respective channel names.
 * The pointer is valid only up to next PubNub method call in the same
 * pubnub context, make a copy if you need it to persist. */
char **pubnub_sync_last_channels(struct pubnub_sync *sync);

#ifdef __cplusplus
}
#endif

#endif
