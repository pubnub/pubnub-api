#ifndef PUBNUB__PubNub_libevent_h
#define PUBNUB__PubNub_libevent_h

#include <pubnub.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque objects. */
struct pubnub_libevent;
struct json_object;

/* Callback structure to pass pubnub_init(). */
extern const struct pubnub_callbacks pubnub_libevent_callbacks;

/* Callback data to pass pubnub_init(). */
struct pubnub_libevent *pubnub_libevent_init(void);

#ifdef __cplusplus
}
#endif

#endif
