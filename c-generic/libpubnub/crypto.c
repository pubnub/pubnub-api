#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <json.h>

#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/md5.h>
#include <openssl/sha.h>

#include "crypto.h"
#include "pubnub-priv.h"

char *
pubnub_signature(struct pubnub *p, const char *channel, const char *message_str)
{
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

	char *signature = malloc(33);
	for (int i = 0; i < 16; i++) {
		snprintf(&signature[i * 2], 3, "%02x", digest[i]);
	}
	/* The snprintf() in the last iteration implicitly
	 * NUL-terminates signature[]. */

	return signature;
}


/* PubNub follows an *ahem* specific procedure when preprocessing
 * the cipher key. */
static unsigned char *
pubnub_sha256_cipher_key(const char *cipher_key, unsigned char cipher_hash[33])
{
	SHA256_CTX sha256;
	SHA256_Init(&sha256);
	SHA256_Update(&sha256, cipher_key, strlen(cipher_key));
	unsigned char digest[SHA256_DIGEST_LENGTH];
	SHA256_Final(digest, &sha256);

	for (int i = 0; i < 16 /* sic, not 32 */; i++) {
		snprintf((char *) &cipher_hash[i * 2], 3, "%02x", digest[i]);
	}

	return cipher_hash;
}

struct json_object *
pubnub_encrypt(const char *cipher_key, const char *message_str)
{
	unsigned char iv[] = "0123456789012345";

	/* Pre-process (hash) encryption key */

	unsigned char cipher_hash[33];
	pubnub_sha256_cipher_key(cipher_key, cipher_hash);

	/* Encrypt the message */

	EVP_CIPHER_CTX aes256;
	EVP_CIPHER_CTX_init(&aes256);
	if (!EVP_EncryptInit_ex(&aes256, EVP_aes_256_cbc(), NULL, cipher_hash, iv)) {
		DBGMSG("EncryptInit error\n");
		return NULL;
	}

	int message_len = strlen(message_str);
	unsigned char *cipher_data = malloc(message_len + EVP_CIPHER_block_size(EVP_aes_256_cbc()));
	int cipher_len = 0;

	if (!EVP_EncryptUpdate(&aes256, cipher_data, &cipher_len, (unsigned char *) message_str, message_len)) {
		DBGMSG("EncryptUpdate error\n");
		return NULL;
	}
	int cipher_flen;
	if (!EVP_EncryptFinal_ex(&aes256, cipher_data + cipher_len, &cipher_flen)) {
		DBGMSG("EncryptFinal error\n");
		return NULL;
	}
	cipher_len += cipher_flen;
	EVP_CIPHER_CTX_cleanup(&aes256);

	/* Convert to base64 representation */

	BIO *b64f = BIO_new(BIO_f_base64());
	BIO_set_flags(b64f, BIO_FLAGS_BASE64_NO_NL);
	BIO *bmem = BIO_new(BIO_s_mem());
	BIO *b64 = BIO_push(b64f, bmem);
	if (BIO_write(b64, cipher_data, cipher_len) != cipher_len) {
		DBGMSG("b64 write error\n");
		return NULL;
	}
	if (BIO_flush(b64) != 1) {
		DBGMSG("b64 flush error\n");
		return NULL;
	}

	/* Conjure up JSON object */

	unsigned char *b64_str;
	long b64_len = BIO_get_mem_data(b64, &b64_str);
	struct json_object *message = json_object_new_string_len((char *) b64_str, b64_len);

	/* Clean up. */

	BIO_free_all(b64);
	free(cipher_data);

	return message;
}

static struct json_object *
pubnub_decrypt(const char *cipher_key, const char *b64_str)
{
	int b64_len = strlen(b64_str);
	unsigned char iv[] = "0123456789012345";

	/* Pre-process (hash) encryption key */

	unsigned char cipher_hash[33];
	pubnub_sha256_cipher_key(cipher_key, cipher_hash);

	/* Convert base64 encrypted text to raw data. */

	BIO *b64f = BIO_new(BIO_f_base64());
	BIO_set_flags(b64f, BIO_FLAGS_BASE64_NO_NL);
	BIO *bmem = BIO_new_mem_buf((unsigned char *) b64_str, b64_len);
	BIO *b64 = BIO_push(b64f, bmem);
	/* b64_len is fine upper bound for raw data length... */
	unsigned char *cipher_data = malloc(b64_len);
	int cipher_len = BIO_read(b64, cipher_data, b64_len);
	BIO_free_all(b64);

	/* Decrypt the message */

	EVP_CIPHER_CTX aes256;
	EVP_CIPHER_CTX_init(&aes256);
	if (!EVP_DecryptInit_ex(&aes256, EVP_aes_256_cbc(), NULL, cipher_hash, iv)) {
		DBGMSG("DecryptInit error\n");
		return NULL;
	}

	char *message_str = malloc(cipher_len + EVP_CIPHER_block_size(EVP_aes_256_cbc()) + 1);
	int message_len = 0;
	if (!EVP_DecryptUpdate(&aes256, (unsigned char *) message_str, &message_len, cipher_data, cipher_len)) {
		DBGMSG("DecryptUpdate error\n");
		return NULL;
	}
	int message_flen;
	if (!EVP_DecryptFinal_ex(&aes256, (unsigned char *) message_str + message_len, &message_flen)) {
		DBGMSG("DecryptFinal error\n");
		return NULL;
	}
	message_len += message_flen;

	EVP_CIPHER_CTX_cleanup(&aes256);
	free(cipher_data);

	/* Conjure up JSON object */

	message_str[message_len] = 0;
	DBGMSG("dec inp: <%s>\n", message_str);
	struct json_object *message = json_tokener_parse(message_str);
	free(message_str);
	return message;
}

struct json_object *
pubnub_decrypt_array(const char *cipher_key, struct json_object *message_list)
{
	int msg_n = json_object_array_length(message_list);
	struct json_object *newlist = json_object_new_array();

	for (int i = 0; i < msg_n; i++) {
		struct json_object *msg = json_object_array_get_idx(message_list, i);
		if (!json_object_is_type(msg, json_type_string)) {
			DBGMSG("decrypt fail: message not a string\n");
error:
			/* Format error. This is a most stringent approach. */
			json_object_put(newlist);
			return NULL;
		}

		DBGMSG("decrypting %s\n", json_object_get_string(msg));
		struct json_object *newmsg = pubnub_decrypt(cipher_key, json_object_get_string(msg));
		if (!newmsg) {
			DBGMSG("decrypt fail: message cannot be decrypted\n");
			goto error;
		}

		json_object_array_add(newlist, newmsg);
	}

	return newlist;
}

#if 0
/* Few simple tests. */
int
main(void)
{
	struct json_object *msg;

	msg = pubnub_encrypt("enigma", "{}");
	if (!msg) return EXIT_FAILURE;
	printf("E\t{}\t%s\tIDjZE9BHSjcX67RddfCYYg==\n", json_object_get_string(msg));
	json_object_put(msg);

	msg = pubnub_encrypt("enigma", "[]");
	if (!msg) return EXIT_FAILURE;
	printf("E\t[]\t%s\tNs4TB41JjT2NCXaGLWSPAQ==\n", json_object_get_string(msg));
	json_object_put(msg);

	msg = pubnub_encrypt("enigma", "\"Pubnub Messaging API 1\"");
	if (!msg) return EXIT_FAILURE;
	printf("E\t\"Pubnub Messaging API 1\"\t%s\tf42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=\n", json_object_get_string(msg));
	json_object_put(msg);

	msg = pubnub_encrypt("enigma", "{\"this stuff\":{\"can get\":\"complicated!\"}}");
	if (!msg) return EXIT_FAILURE;
	printf("E\t{\"this stuff\":{\"can get\":\"complicated!\"}}\t%s\tzMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF\n", json_object_get_string(msg));
	json_object_put(msg);

	msg = json_object_new_array();
	json_object_array_add(msg, json_object_new_string("Ns4TB41JjT2NCXaGLWSPAQ=="));
	struct json_object *newa = pubnub_decrypt_array("enigma", msg);
	if (!newa) return EXIT_FAILURE;
	printf("D\tNs4TB41JjT2NCXaGLWSPAQ==\t%s\t[]\n", json_object_get_string(json_object_array_get_idx(newa, 0)));

	return EXIT_SUCCESS;
}
#endif
