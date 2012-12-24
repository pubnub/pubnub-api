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
struct json_object *pubnub_sync_last_response(struct pubnub_sync *sync);

/* Return name of the channel carrying the message returned by the last
 * subscribe method call. free() the pointer when you are going to drop
 * the reference. */
char *pubnub_sync_last_channel(struct pubnub_sync *sync);

#ifdef __cplusplus
}
#endif

#endif
