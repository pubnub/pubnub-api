#include <ctype.h>
#include <Ethernet.h>
#include "PubNub.h"

class PubNub PubNub;

bool PubNub::begin(char *publish_key_, char *subscribe_key_, char *origin_)
{
	publish_key = publish_key_;
	subscribe_key = subscribe_key_;
	origin = origin_;
}

EthernetClient *PubNub::publishRaw(char *channel, char *message)
{
	EthernetClient &client = publish_client;
	if (!client.connect(origin, 80)) {
		client.stop();
		return NULL;
	}

	client.print("GET /publish/");
	client.print(publish_key);
	client.print("/");
	client.print(subscribe_key);
	client.print("/0/");
	client.print(channel);
	client.print("/0/");

	/* Inject message, URI-escaping it in the process.
	 * We are careful to save RAM by not using any copies
	 * of the string or explicit buffers. */
	char *pmessage = message;
	while (pmessage[0]) {
		/* RFC 3986 Unreserved characters plus few
		 * safe reserved ones. */
		size_t okspan = strspn(pmessage, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~" ",=:;@[]");
		if (okspan > 0) {
			client.write((const uint8_t *) pmessage, okspan);
			pmessage += okspan;
		}
		if (pmessage[0]) {
			/* %-encode a non-ok character. */
			char enc[3] = {'%'};
			enc[1] = "0123456789ABCDEF"[pmessage[0] / 16];
			enc[2] = "0123456789ABCDEF"[pmessage[0] % 16];
			client.write((const uint8_t *) enc, 3);
			pmessage++;
		}
	}

	if (this->_request_bh(client)) {
		/* Success and reached body, return handle to the client
		 * for further perusal. */
		return &client;
	} else {
		/* Failure. */
		client.stop();
		return NULL;
	}
}

EthernetClient *PubNub::subscribeRaw(char *channel)
{
	EthernetClient &client = subscribe_client;
	if (!client.connect(origin, 80)) {
		client.stop();
		return NULL;
	}

	client.print("GET /subscribe/");
	client.print(subscribe_key);
	client.print("/");
	client.print(channel);
	client.print("/0/0"); // TODO timetoken

	if (this->_request_bh(client)) {
		/* Success and reached body, return handle to the client
		 * for further perusal. */
		return &client;
	} else {
		/* Failure. */
		client.stop();
		return NULL;
	}
}

EthernetClient *PubNub::historyRaw(char *channel, int limit)
{
	EthernetClient &client = history_client;
	if (!client.connect(origin, 80)) {
		client.stop();
		return NULL;
	}

	client.print("GET /history/");
	client.print(subscribe_key);
	client.print("/");
	client.print(channel);
	client.print("/0/");
	client.print(limit, DEC);

	if (this->_request_bh(client)) {
		/* Success and reached body, return handle to the client
		 * for further perusal. */
		return &client;
	} else {
		/* Failure. */
		client.stop();
		return NULL;
	}
}

bool PubNub::_request_bh(EthernetClient &client)
{
	/* Finish the first line of the request. */
	client.println(" HTTP/1.1");
	/* Finish HTTP request. */
	client.print("Host: ");
	client.println(origin);
	client.println("User-Agent: PubNub-Arduino/1.0");
	client.println("Connection: close");
	client.println();

#define WAIT() do { \
	while (client.connected() && !client.available()) /* wait */; \
	if (!client.connected()) { \
		/* Oops, connection interrupted. */ \
		return false; \
	} \
} while (0)

	/* Read first line with HTTP code. */
	/* "HTTP/1.x " */
	do {
		WAIT();
	} while (client.read() != ' ');
	/* Now, first digit of HTTP code. */
	WAIT();
	char c = client.read();
	if (c != '2') {
		/* HTTP code that is NOT 2xx means trouble.
		 * kthxbai */
		return false;
	}

	/* Skip the rest of headers. */
	while (client.connected()) {
		/* Wait until we get "\r\n\r\n" sequence (i.e., empty line
		 * that separates HTTP header and body). */
		WAIT();
		if (client.read() != '\r') continue;
		WAIT();
		if (client.read() != '\n') continue;
		WAIT();
		if (client.read() != '\r') continue;
		WAIT();
		if (client.read() != '\n') continue;

		/* Good! Body begins now. */
		return true;
	}
	/* No body means error. */
	return false;
}
