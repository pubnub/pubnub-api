#ifndef PubNub_h
#define PubNub_h

#include <stdint.h>
#include <Ethernet.h>


/* Some notes:
 *
 * (i) There is no SSL support on Arduino, it is unfeasible with
 * Arduino Uno or even Arduino Mega's computing power and memory limits.
 * All the traffic goes on the wire unencrypted and unsigned.
 *
 * (ii) We re-resolve the origin server IP address before each request.
 * This means some slow-down for intensive communication, but we rather
 * expect light traffic and very long-running sketches (days, months),
 * where refreshing the IP address is quite desirable.
 *
 * (iii) We let the users read replies at their leisure instead of
 * returning an already preloaded string so that (a) they can do that
 * in loop() code while taking care of other things as well (b) we don't
 * waste precious RAM by pre-allocating buffers that are never needed.
 *
 * (iv) If you are having problems connecting, maybe you have hit
 * a bug in Debian's version of Arduino pertaining the DNS code. Try using
 * an IP address as origin and/or upgrading your Arduino package.
 */


class PubNub {
public:
	/* Init the Pubnub Client API
	 *
	 * This should be called after Ethernet.begin().
	 * Note that the string parameters are not copied; do not
	 * overwrite or free the memory where you stored the keys!
	 * (If you are passing string literals, don't worry about it.)
	 * Note that you should run only a single publish at once.
	 *
	 * @param string publish_key required key to send messages.
	 * @param string subscribe_key required key to receive messages.
	 * @param string origin optional setting for cloud origin.
	 * @return boolean whether begin() was successful. */
	bool begin(char *publish_key, char *subscribe_key, char *origin = "pubsub.pubnub.com");

	/* Publish (raw)
	 *
	 * Send a message (assumed to be well-formed JSON) to a given channel.
	 *
	 * Note that the reply can be obtained using code like:
	     client = publishRaw("demo", "\"lala\"");
	     if (!client) return; // error
	     while (client->connected()) {
	       while (client->connected() && !client->available()) ; // wait
	       char c = client->read();
	       Serial.print(c);
	     }
	     client->stop();
	 * You will get content right away, the header has been already
	 * skipped inside the function. If you do not care about
	 * the reply, just call client->stop(); immediately.
	 *
	 * @param string channel required channel name.
	 * @param string message required message string in JSON format.
	 * @return string Stream-ish object with reply message or NULL on error. */
	EthernetClient *publishRaw(char *channel, char *message);

	/**
	 * Subscribe (raw)
	 *
	 * Listen for a message on a given channel. The function will block
	 * and return when a message arrives. Typically, you will run this
	 * function from loop() function to keep listening for messages
	 * indefinitely.
	 *
	 * TODO timer
	 * TODO empty output
	 *
	 * TODO rest of documentation
	 *
	 * @param string channel required channel name. */
	EthernetClient *subscribeRaw(char *channel);

	/* TODO document */
	EthernetClient *historyRaw(char *channel, int limit = 10);

private:
	bool _request_bh(EthernetClient &client, bool chunked = true);

	char *publish_key, *subscribe_key;
	char *origin;

	EthernetClient publish_client, subscribe_client, history_client;
};

extern class PubNub PubNub;

#endif
