#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <json.h>

#include "pubnub.h"
#include "pubnub-sync.h"

int
main(void)
{
	struct pubnub_sync *sync = pubnub_sync_init();
	struct pubnub *p = pubnub_init("demo", "demo", NULL, &pubnub_sync_callbacks, sync);
	json_object *msg;


	/* Publish */

	msg = json_object_new_object();
	json_object_object_add(msg, "num", json_object_new_int(42));
	json_object_object_add(msg, "str", json_object_new_string("\"Hello, world!\" she said."));

	pubnub_publish(p, "my_channel", msg, 0, NULL, NULL);

	json_object_put(msg);

	if (pubnub_sync_last_result(sync) != PNR_OK) {
		fprintf(stderr, "pubnub publish error: %d\n", pubnub_sync_last_result(sync));
		return EXIT_FAILURE;
	}
	msg = pubnub_sync_last_response(sync);
	printf("pubnub publish ok: %s\n", json_object_get_string(msg));
	json_object_put(msg);


	/* History */

	pubnub_history(p, "my_channel", 10, 0, NULL, NULL);
	if (pubnub_sync_last_result(sync) != PNR_OK) {
		fprintf(stderr, "pubnub history error: %d\n", pubnub_sync_last_result(sync));
		return EXIT_FAILURE;
	}
	msg = pubnub_sync_last_response(sync);
	printf("pubnub history ok: %s\n", json_object_get_string(msg));
	json_object_put(msg);


	/* TODO subscribe */


	pubnub_done(p);
}
