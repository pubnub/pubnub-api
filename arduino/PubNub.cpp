#include <ctype.h>
#include <Ethernet.h>
#include "PubNub.h"

// #define PUBNUB_DEBUG 1

#ifdef PUBNUB_DEBUG
#define DBGprint(x...) Serial.print(x)
#define DBGprintln(x...) Serial.println(x)
#else
#define DBGprint(x...)
#define DBGprintln(x...)
#endif

class PubNub PubNub;

bool PubNub::begin(char *publish_key_, char *subscribe_key_, char *origin_)
{
	publish_key = publish_key_;
	subscribe_key = subscribe_key_;
	origin = origin_;
}

EthernetClient *PubNub::publish(char *channel, char *message, int timeout)
{
	EthernetClient &client = publish_client;
	unsigned long t_start;

retry:
	t_start = millis();
	/* connect() timeout is about 30s, much lower than our usual
	 * timeout is. */
	if (!client.connect(origin, 80)) {
		DBGprintln("Connection error");
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

	enum PubNub_BH ret = this->_request_bh(client, t_start, timeout);
	switch (ret) {
	case PubNub_BH_OK:
		/* Success and reached body, return handle to the client
		 * for further perusal. */
		return &client;
	case PubNub_BH_ERROR:
		/* Failure. */
		client.stop();
		return NULL;
	case PubNub_BH_TIMEOUT:
		/* Time out. Try again. */
		client.stop();
		goto retry;
	}
}

PubSubClient *PubNub::subscribe(char *channel, int timeout)
{
	PubSubClient &client = subscribe_client;
	unsigned long t_start;

retry:
	t_start = millis();
	/* connect() timeout is about 30s, much lower than our usual
	 * timeout is. */
	if (!client.connect(origin, 80)) {
		DBGprintln("Connection error");
		client.stop();
		return NULL;
	}

	client.print("GET /subscribe/");
	client.print(subscribe_key);
	client.print("/");
	client.print(channel);
	client.print("/0/");
	client.print(client.server_timetoken());

	enum PubNub_BH ret = this->_request_bh(client, t_start, timeout);
	switch (ret) {
	case PubNub_BH_OK:
		/* Success and reached body. We need to eat '[' first,
		 * as our API contract is to return only the "message body"
		 * part of reply from subscribe. */
		if (!client.wait_for_data()
		    || !client.connected()
		    || client.read() != '[') {
			/* Something unexpected. */
			DBGprintln("Unexpected body in subscribe");
			client.stop();
			return NULL;
		}
		/* Now return handle to the client for further perusal.
		 * PubSubClient class will make sure that the client does
		 * not see the time token but we stop right after the
		 * message body. */
		client.start_body();
		return &client;

	case PubNub_BH_ERROR:
		/* Failure. */
		client.stop();
		return NULL;

	case PubNub_BH_TIMEOUT:
		/* Time out. Try again. */
		client.stop();
		goto retry;
	}
}

EthernetClient *PubNub::history(char *channel, int limit, int timeout)
{
	EthernetClient &client = history_client;
	unsigned long t_start;

retry:
	t_start = millis();
	if (!client.connect(origin, 80)) {
		DBGprintln("Connection error");
		client.stop();
		return NULL;
	}

	client.print("GET /history/");
	client.print(subscribe_key);
	client.print("/");
	client.print(channel);
	client.print("/0/");
	client.print(limit, DEC);

	enum PubNub_BH ret = this->_request_bh(client, t_start, timeout);
	switch (ret) {
	case PubNub_BH_OK:
		/* Success and reached body, return handle to the client
		 * for further perusal. */
		return &client;
	case PubNub_BH_ERROR:
		/* Failure. */
		client.stop();
		return NULL;
	case PubNub_BH_TIMEOUT:
		/* Time out. Try again. */
		client.stop();
		goto retry;
	}
}

enum PubNub_BH PubNub::_request_bh(EthernetClient &client, unsigned long t_start, int timeout)
{
	/* Finish the first line of the request. */
	client.print(" HTTP/1.1\r\n");
	/* Finish HTTP request. */
	client.print("Host: ");
	client.print(origin);
	client.print("\r\nUser-Agent: PubNub-Arduino/1.0\r\nConnection: close\r\n\r\n");

#define WAIT() do { \
	while (client.connected() && !client.available()) { \
		/* wait, just check for timeout */ \
		if (millis() - t_start > (unsigned long) timeout * 1000) { \
			DBGprintln("Timeout in bottom half"); \
			return PubNub_BH_TIMEOUT; \
		} \
	} \
	if (!client.connected()) { \
		/* Oops, connection interrupted. */ \
		DBGprintln("Connection reset in bottom half"); \
		return PubNub_BH_ERROR; \
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
		DBGprint("Wrong HTTP status first digit ");
		DBGprint((int) c, DEC);
		DBGprintln(" in bottom half");
		return PubNub_BH_ERROR;
	}

	/* Now, we enter in a state machine that shall guide us through
	 * the remaining headers to the beginning of the body. */
	enum {
		RS_SKIPLINE, /* Skip the rest of this line. */
		RS_LOADLINE, /* Try loading the line in a buffer. */
	} request_state = RS_SKIPLINE; /* Skip the rest of status line first. */
	bool chunked = false;

	while (client.connected()) {
		/* Let's hope there is no stray LF without CR. */
		if (request_state == RS_SKIPLINE) {
			do {
				WAIT();
			} while (client.read() != '\n');
			request_state = RS_LOADLINE;

		} else { /* request_state == RS_LOADLINE */
			/* line[] must be enough to hold
			 * Transfer-Encoding: chunked (or \r\n) */
			const static char chunked_str[] = "Transfer-Encoding: chunked\r\n";
			char line[sizeof(chunked_str)]; /* Not NUL-terminated! */
			int linelen = 0;
			char ch = 0;
			do {
				WAIT();
				ch = client.read();
				line[linelen++] = ch;
				if (linelen == sizeof(chunked_str)
				    && !strncasecmp(line, chunked_str, linelen)) {
					/* Chunked encoding header. */
					chunked = true;
					break;
				}
			} while (ch != '\n' && linelen < sizeof(line));
			if (ch != '\n') {
				/* We are not at the end of the line yet.
				 * Skip the rest of the line. */
				request_state = RS_SKIPLINE;
			} else if (linelen == 2 && line[0] == '\r') {
				/* Empty line. This means headers end. */
				break;
			}
		}
	}

	if (chunked) {
		/* There is one extra line due to Transfer-encoding: chunked.
		 * Our minimalistic support means that we hope for just
		 * a single chunk, just skip the first line after header. */
		do {
			WAIT();
		} while (client.read() != '\n');
	}

	/* Body begins now. */
	return PubNub_BH_OK;
}


int PubSubClient::read()
{
	int c = EthernetClient::read();
	if (!json_enabled || c == -1)
		return c;

	this->_state_input(c, NULL, 0);
	return c;
}

int PubSubClient::read(uint8_t *buf, size_t size)
{
	int len = EthernetClient::read(buf, size);
	if (!json_enabled || len <= 0)
		return len;
	for (int i = 0; i < len; i++) {
		this->_state_input(buf[i], &buf[i+1], len - i - 1);
		if (!connected()) {
			/* We have hit the end somewhere in this buffer.
			 * From user perspective, only characters up to
			 * index i are valid. */
			return i + 1;
		}
	}
	return len;
}

bool PubSubClient::wait_for_data(int timeout)
{
	unsigned long t_start = millis();
	while (connected() && !available()) {
		if (millis() - t_start > (unsigned long) timeout * 1000)
			return false; /* Time out. */
	}
	return connected();
}

void PubSubClient::stop()
{
	if (!connected() || !json_enabled) {
		EthernetClient::stop();
		return;
	}
	/* We are still connected. Read the rest of the stream so that
	 * we catch the timetoken. */
	while (wait_for_data()) {
		char ch = read();
		this->_state_input(ch, NULL, 0);
	}
	json_enabled = false;
}

void PubSubClient::start_body()
{
	json_enabled = true;
	in_string = after_backslash = false;
	braces_depth = 0;
}

void PubSubClient::_state_input(uint8_t ch, uint8_t *nextbuf, size_t nextsize)
{
	/* Process a single character on input, updating the JSON
	 * state machine. If we reached the last character of input
	 * (just before expected ","), we will eat the rest of the body,
	 * update timetoken and close the connection. */
	if (in_string) {
		if (after_backslash) {
			/* Whatever this is... */
			after_backslash = false;
			return;
		}
		switch (ch) {
		case '"':
			in_string = false;
			if (braces_depth == 0)
				goto body_end;
			return;
		case '\\':
			after_backslash = true;
			return;
		default:
			return;
		}

	} else {
		switch (ch) {
		case '"':
			in_string = true;
			return;
		case '{':
		case '[':
			braces_depth++;
			return;
		case '}':
		case ']':
			braces_depth--;
			if (braces_depth <= 0)
				goto body_end;
			return;
		default:
			return;
		}
	}

	return;
body_end:
	/* End of data here. */
	this->_grab_timetoken(nextbuf, nextsize);
}

void PubSubClient::_grab_timetoken(uint8_t *nextbuf, size_t nextsize)
{
	char new_timetoken[22];
	size_t new_timetoken_len = 0;

	/* Expected followup now is:
	 * 	,"13511688131075270"]
	 */
	/* Somewhat unwieldy macros that will first exhaust nextbuf[],
	 * then read directly from socket. */
#define WAIT() do { \
	if (nextsize > 0) \
		break; \
	if (!wait_for_data()) { \
		/* Oops, connection interrupted. */ \
		return; \
	} \
} while (0)
#define GETCHAR() (nextsize > 0 ? (nextsize--, *nextbuf++) : read())
	do { WAIT(); } while (GETCHAR() != ',');
	do { WAIT(); } while (GETCHAR() != '"');
	do {
		WAIT();
		char ch = GETCHAR();
		if (ch == '"')
			break;
		new_timetoken[new_timetoken_len++] = ch;
		if (new_timetoken_len >= sizeof(new_timetoken) - 1)
			break;
	} while (1);
	memcpy(timetoken, new_timetoken, new_timetoken_len);
	timetoken[new_timetoken_len] = 0;
}
