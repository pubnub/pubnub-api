#ifndef PUBNUB__crypto_h
#define PUBNUB__crypto_h

struct pubnub;

char *pubnub_signature(struct pubnub *p, const char *channel, const char *message_str);

#endif
