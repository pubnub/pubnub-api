#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <json.h>

#include "pubnub.h"
#include "pubnub-sync.h"

int
main(void)
{
	struct pubnub_sync *sync = pubnub_sync_init();
	struct pubnub *p = pubnub_init(
			/* publish_key */ "demo",
			/* subscribe_key */ "demo",
			/* secret_key for signing */ NULL,
			/* cipher_key for encryption */ NULL,
			/* origin, by default pubsub.pubnub.com" */ NULL,
			/* pubnub_callbacks */ &pubnub_sync_callbacks,
			/* pubnub_callbacks data */ sync);
	json_object *msg;


	/* Publish */

	msg = json_object_new_object();
	json_object_object_add(msg, "num", json_object_new_int(42));
	json_object_object_add(msg, "str", json_object_new_string("\"Hello, world!\" she said."));

	pubnub_publish(
			/* struct pubnub */ p,
			/* channel */ "my_channel",
			/* message */ msg,
			/* timeout */ 0,
			/* callback; sync needs NULL! */ NULL,
			/* callback data */ NULL);

	json_object_put(msg);

	if (pubnub_sync_last_result(sync) != PNR_OK) {
		msg = pubnub_sync_last_response(sync);
		fprintf(stderr, "pubnub publish error: %d [%s]\n", pubnub_sync_last_result(sync), json_object_get_string(msg));
		json_object_put(msg);
		return EXIT_FAILURE;
	}
	msg = pubnub_sync_last_response(sync);
	printf("pubnub publish ok: %s\n", json_object_get_string(msg));
	json_object_put(msg);


	/* History */

	pubnub_history(
			/* struct pubnub */ p,
			/* channel */ "my_channel",
			/* #messages */ 10,
			/* timeout */ 0,
			/* callback; sync needs NULL! */ NULL,
			/* callback data */ NULL);
	if (pubnub_sync_last_result(sync) != PNR_OK) {
		msg = pubnub_sync_last_response(sync);
		fprintf(stderr, "pubnub history error: %d [%s]\n", pubnub_sync_last_result(sync), json_object_get_string(msg));
		json_object_put(msg);
		return EXIT_FAILURE;
	}
	msg = pubnub_sync_last_response(sync);
	printf("pubnub history ok: %s\n", json_object_get_string(msg));
	json_object_put(msg);


	/* Subscribe */

	do {
		const char *channels[] = { "my_channel", "demo_channel" };
		pubnub_subscribe_multi(
				/* struct pubnub */ p,
				/* list of channels */ channels,
				/* number of listed channels */ 2,
				/* timeout */ 300,
				/* callback; sync needs NULL! */ NULL,
				/* callback data */NULL);
		if (pubnub_sync_last_result(sync) == PNR_TIMEOUT) {
			fprintf(stderr, "Time out after 300s reached. Forcibly re-issuing.\n");
			continue;
		}
		if (pubnub_sync_last_result(sync) != PNR_OK) {
			msg = pubnub_sync_last_response(sync);
			fprintf(stderr, "pubnub subscribe error: %d [%s]\n", pubnub_sync_last_result(sync), json_object_get_string(msg));
			json_object_put(msg);
			return EXIT_FAILURE;
		}
		msg = pubnub_sync_last_response(sync);
		if (json_object_array_length(msg) == 0) {
			printf("pubnub subscribe ok, no news\n");
		} else {
			char **msg_channels = pubnub_sync_last_channels(sync);
			for (int i = 0; i < json_object_array_length(msg); i++) {
				json_object *msg1 = json_object_array_get_idx(msg, i);
				printf("pubnub subscribe [%s]: %s\n", msg_channels[i], json_object_get_string(msg1));
			}
		}
		json_object_put(msg);
		sleep(1);
	} while (1);


	pubnub_done(p);
	return EXIT_SUCCESS;
}
