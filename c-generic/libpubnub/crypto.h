#ifndef PUBNUB__crypto_h
#define PUBNUB__crypto_h

struct pubnub;
struct json_object;

char *pubnub_signature(struct pubnub *p, const char *channel, const char *message_str);
struct json_object *pubnub_encrypt(const char *cipher_key, const char *message_str);
struct json_object *pubnub_decrypt_array(const char *cipher_key, struct json_object *message_list);

#endif
