#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <event.h>

#include <json.h>

#include "pubnub.h"
#include "pubnub-libevent.h"


/* We must ensure that only one method call is in progress at once within a
 * single context, this is the libpubnub requirement. There are many things to
 * take care of, common issues that show up in a variety of multi-threading as
 * well.
 *
 * For example, what to do if we want to regularly publish messages but are hit
 * with a stuck message - shall we maintain a queue of messages to publish,
 * create a new context for publishing the new message in parallel, or just
 * swallow the PNR_OCCUPIED error and drop the message? All three answers are
 * right, it just depends on your scenario (is ordering or latency more
 * important? is history important?). */

/* We will concern ourselves with these strategies in other examples. Here, we
 * will demonstrate just a simple sequential usage, our demo will just first
 * publish a single message, then retrieve history of last N messages, then
 * enter a subscription "loop". The calls will be stringed in sequential order
 * by callbacks.
 *
 * To showcase that this is all asynchronous, independent of the above a clock
 * will be shown at the last line of output, updated every second. */


/* The clock update timer. */

struct event clock_update_timer;
static void
clock_update(int fd, short kind, void *userp)
{
	/* Print current time. */
	time_t t = time(NULL);
	int now_s = t % 60;
	int now_m = (t / 60) % 60;
	int now_h = (t / 3600) % 24;
	/* The trailing \r will make cursor return to the beginning
	 * of the current line. */
	printf("%02d:%02d:%02d\r", now_h, now_m, now_s);
	fflush(stdout);

	/* Next clock update in one second. */
	/* (A more prudent timer strategy would be to update clock
	 * on the next second _boundary_.) */
	struct timeval timeout = { .tv_sec = 1, .tv_usec = 0 };
	evtimer_add(&clock_update_timer, &timeout);
}


/* The callback chain.
 *
 * Below, we have many separate functions, but the control flow
 * is mostly linear, so just continue reading in next function
 * when you finish the previous one. The code is split to functions
 * (i) when issuing a call that must be handled asynchronously, and
 * (ii) for clarity. */

static void publish(struct pubnub *p);
static void publish_done(struct pubnub *p, enum pubnub_res result, struct json_object *response, void *ctx_data, void *call_data);

static void history(struct pubnub *p);
static void history_received(struct pubnub *p, enum pubnub_res result, struct json_object *msg, void *ctx_data, void *call_data);

static void subscribe(struct pubnub *p);
static void subscribe_received(struct pubnub *p, enum pubnub_res result, char **channels, struct json_object *msg, void *ctx_data, void *call_data);

static void
publish(struct pubnub *p)
{
	json_object *msg = json_object_new_object();
	json_object_object_add(msg, "num", json_object_new_int(42));
	json_object_object_add(msg, "str", json_object_new_string("\"Hello, world!\" she said."));

	pubnub_publish(p, "my_channel", msg, 0, publish_done, NULL);

	json_object_put(msg);

	/* ...continues later in publish_done(). */
}

static void
publish_done(struct pubnub *p, enum pubnub_res result, struct json_object *msg, void *ctx_data, void *call_data)
{
	/* ctx_data is (struct pubnub_libevent *) */
	/* call_data is NULL as that's what we passed to pubnub_publish() */

	if (result != PNR_OK) {
		fprintf(stderr, "pubnub publish error: %d [%s]\n", result, msg ? json_object_get_string(msg) : "N/A");
		if (msg) json_object_put(msg);
		/* Instead of a retry strategy, we just terminate
		 * with an error. You might choose to do differently. */
		exit(EXIT_FAILURE);
	}

	printf("pubnub publish ok\n");

	/* Next step in the sequence is retrieving history. */

	history(p);
}


static void
history(struct pubnub *p)
{
	pubnub_history(p, "my_channel", 10, 0, history_received, NULL);

	/* ...continues later in history_received(). */
}

static void
history_received(struct pubnub *p, enum pubnub_res result, struct json_object *msg, void *ctx_data, void *call_data)
{
	/* ctx_data is (struct pubnub_libevent *) */
	/* call_data is NULL as that's what we passed to pubnub_history() */

	if (result != PNR_OK) {
		fprintf(stderr, "pubnub history error: %d [%s]\n", result, msg ? json_object_get_string(msg) : "N/A");
		if (msg) json_object_put(msg);
		/* Instead of a retry strategy, we just terminate
		 * with an error. You might choose to do differently. */
		exit(EXIT_FAILURE);
	}

	printf("pubnub history ok: %s\n", json_object_get_string(msg));
	json_object_put(msg);


	/* Next step in the sequence is entering the subscribe "loop". */

	subscribe(p);
}


/* How does channel subscription work? The subscribe() call will issue
 * a PubNub subscribe request and call subscribe_received() when some
 * messages arrived. subscribe_received() will process the messages,
 * then "loop" by calling subscribe() again to issue a new request.
 *
 * Sometimes (on errors), the subsequenty subscribe() call will be
 * delayed by funneling it through subscribe_retry_timer that will
 * call subscribe_retry(). */

static void
subscribe(struct pubnub *p)
{
	const char *channels[] = { "my_channel", "demo_channel" };
	pubnub_subscribe_multi(p, channels, 2, 300, subscribe_received, NULL);

	/* ...continues later in subscribe_received(). */
}

/* Delayed retry handling intermezzo. */
struct event subscribe_retry_timer;
static void
subscribe_retry(int fd, short kind, void *userp)
{
	subscribe(userp);
}

static void
subscribe_received(struct pubnub *p, enum pubnub_res result, char **channels, struct json_object *msg, void *ctx_data, void *call_data)
{
	/* ctx_data is (struct pubnub_libevent *) */
	/* call_data is NULL as that's what we passed to pubnub_subscribe_multi() */

	if (result == PNR_TIMEOUT) {
		fprintf(stderr, "Time out after 300s reached. Forcibly re-issuing.\n");
		subscribe(p);
		return;
	}

	if (result != PNR_OK) {
		fprintf(stderr, "pubnub subscribe error: %d [%s]\n", result, msg ? json_object_get_string(msg) : "N/A");
		if (msg) json_object_put(msg);

		/* We will set up a timer that will make a retry in one second.
		 * You should never retry _immediately_ as that will likely
		 * just cause high CPU load, flood your network and put useless
		 * load on the PubNub servers if some kind of longer outage
		 * happenned. */
		/* TODO: Move this logic to libpubnub itself. */
		evtimer_set(&subscribe_retry_timer, subscribe_retry, p);
		struct timeval timeout = { .tv_sec = 1, .tv_usec = 0 };
		evtimer_add(&subscribe_retry_timer, &timeout);
		return;
	}

	if (json_object_array_length(msg) == 0) {
		printf("pubnub subscribe ok, no news\n");
	} else {
		for (int i = 0; i < json_object_array_length(msg); i++) {
			json_object *msg1 = json_object_array_get_idx(msg, i);
			printf("pubnub subscribe [%s]: %s\n", channels[i], json_object_get_string(msg1));
		}
	}
	json_object_put(msg);

	/* Loop. */
	subscribe(p);
}


int
main(void)
{
	/* Set up the libevent library. */
	event_init();

	/* Set up the PubNub library, with a single shared context,
	 * using the libevent backend for event handling. */
	struct pubnub *p = pubnub_init("demo", "demo", NULL, NULL, NULL, &pubnub_libevent_callbacks, pubnub_libevent_init());

	/* Set the clock update timer. */
	evtimer_set(&clock_update_timer, clock_update, NULL);
	clock_update(-1, EV_TIMEOUT, NULL);

	/* First step in the PubNub call sequence is publishing a message. */
	publish(p);

	/* Here, we could start any other asynchronous operations as needed,
	 * launch a GUI or whatever. */

	/* Start the event loop. */
	event_dispatch();

	/* We should never reach here. */
	pubnub_done(p);
	return EXIT_SUCCESS;
}
