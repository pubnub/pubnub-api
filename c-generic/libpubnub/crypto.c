#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <openssl/md5.h>

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
