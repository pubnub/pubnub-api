#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include <json.h>
#include <wiringPi.h>

#include "pubnub.h"
#include "pubnub-sync.h"


/* See README.md for a brief usage and functional description. */


/* ID identifying this particular RPi. If not passed as an argument,
 * randomly generated on each program run. */
int rpi_id;

// 32 is even more than the current RPi rev. offers
enum pin_type { PIN_OFF, PIN_READ, PIN_WRITE } pins[32];
#define pins_n (sizeof(pins) / sizeof(pins[0]))


void
arg_help(char *argv0)
{
	fprintf(stderr, "Usage: %s [-i RPI_ID] -r READPIN0,READPIN1,... -w WRITEPIN0,WRITEPIN1\n", argv0);
}

void
parse_pinset(const char *pinset_s, enum pin_type type, int wiringPi_mode)
{
	const char *pinset_p = pinset_s;
	do {
		int pin = atoi(pinset_p);
		if (pin > 0 && pin < pins_n) {
			pins[pin] = type;
			pinMode(pin, wiringPi_mode);
		}
		pinset_p = strchr(pinset_p, ',');
		if (!pinset_p)
			break;
		pinset_p++;
	} while (pinset_p);
}

void
publish(struct pubnub *p, struct pubnub_sync *sync, const char *channel, json_object *msg)
{
	printf("pubnub publishing: %s\n", json_object_get_string(msg));
	pubnub_publish(p, channel, msg, 0, NULL, NULL);

	json_object_put(msg);

	if (pubnub_sync_last_result(sync) != PNR_OK) {
		msg = pubnub_sync_last_response(sync);
		fprintf(stderr, "pubnub publish error: %d [%s]\n", pubnub_sync_last_result(sync), json_object_get_string(msg));
		json_object_put(msg);
		exit(EXIT_FAILURE);
	}

	msg = pubnub_sync_last_response(sync);
	printf("pubnub publish ok: %s\n", json_object_get_string(msg));
	json_object_put(msg);
}


void
pong(struct pubnub *p, struct pubnub_sync *sync)
{
	json_object *msg = json_object_new_object();
	json_object_object_add(msg, "id", json_object_new_int(rpi_id));
	publish(p, sync, "rpi_mplayer_status", msg);
}

void
process_message(struct pubnub *p, struct pubnub_sync *sync, json_object *msg)
{
	/* Ignore all messages but what's addressed to us. */

	json_object *id = json_object_object_get(msg, "dest_id");
	if (!id || !json_object_is_type(id, json_type_int))
		return;
	if (json_object_get_int(id) != rpi_id)
		return;

	/* Each reply will have the 'id' field. */

	json_object *reply = json_object_new_object();
	json_object_object_add(reply, "id", json_object_new_int(rpi_id));

	json_object *reply_pins = json_object_new_object();

	/* Any pins to set? */

	json_object *write = json_object_object_get(msg, "write");
	if (write && json_object_is_type(write, json_type_object)) {
		json_object_object_foreach(write, pin, pinval) {
			if (!json_object_is_type(pinval, json_type_int))
				continue;
			int pin_num = atoi(pin);
			if (!(pin_num > 0 && pin_num < pins_n && pins[pin_num] == PIN_WRITE))
				continue;
			/* Set the pin, physically! */
			digitalWrite(pin_num, !!json_object_get_int(pinval));
			/* Store in the reply. */
			json_object_object_add(reply_pins, pin, pinval);
		}
	}

	/* Any pins to read? */
	json_object *read = json_object_object_get(msg, "read");
	if (read && json_object_is_type(read, json_type_array)) {
		for (int i = 0; i < json_object_array_length(read); i++) {
			json_object *pin = json_object_array_get_idx(read, i);
			if (!json_object_is_type(pin, json_type_int))
				continue;
			int pin_num = json_object_get_int(pin);
			if (!(pin_num > 0 && pin_num < pins_n && pins[pin_num] == PIN_READ))
				continue;
			/* Read the pin, physically! */
			int pinval = digitalRead(pin_num);
			/* Store in the reply. */
			char pinstr[8];
			snprintf(pinstr, sizeof(pinstr), "%d", pin_num);
			json_object_object_add(reply_pins, pinstr, json_object_new_int(pinval));
		}
	}

	/* Ok, publish status message. */

	if (json_object_get_object(reply_pins)->head)
		json_object_object_add(reply, "pins", reply_pins);
	else
		json_object_put(reply_pins);

	publish(p, sync, "rpi_mplayer_status", reply);

	json_object_put(reply);
}

int
main(int argc, char *argv[])
{
	/* Initialize wiringPi. */

	if (wiringPiSetup() < 0)
		exit(EXIT_FAILURE);

	/* Parse options. */

	/* Default: */
	srand(time(NULL));
	rpi_id = rand();

	int opt;
	while ((opt = getopt(argc, argv, "i:r:w:")) != -1) {
		switch (opt) {
		case 'i':
			rpi_id = atoi(optarg);
			break;
		case 'r':
			parse_pinset(optarg, PIN_READ, INPUT);
			break;
		case 'w':
			parse_pinset(optarg, PIN_WRITE, OUTPUT);
			break;
		default: /* '?' */
			arg_help(argv[0]);
			exit(EXIT_FAILURE);
		}
	}
	if (optind < argc) {
		arg_help(argv[0]);
		exit(EXIT_FAILURE);
	}


	/* Initialize PubNub. */

	struct pubnub_sync *sync = pubnub_sync_init();
	struct pubnub *p = pubnub_init("demo", "demo", NULL, NULL, NULL, &pubnub_sync_callbacks, sync);


	/* Advertise. */

	pong(p, sync);


	/* Command loop. */

	do {
		pubnub_subscribe(p, "rpi_wiringpi_cmd", 300, NULL, NULL);

		if (pubnub_sync_last_result(sync) == PNR_TIMEOUT) {
			fprintf(stderr, "Time out after 300s reached. Forcibly re-issuing.\n");
			continue;
		}
		if (pubnub_sync_last_result(sync) != PNR_OK) {
			struct json_object *msg = pubnub_sync_last_response(sync);
			fprintf(stderr, "pubnub subscribe error: %d [%s]\n", pubnub_sync_last_result(sync), json_object_get_string(msg));
			json_object_put(msg);
			exit(EXIT_FAILURE);
		}

		struct json_object *msg = pubnub_sync_last_response(sync);
		if (json_object_array_length(msg) == 0) {
			printf("pubnub subscribe ok, no news\n");
		} else {
			for (int i = 0; i < json_object_array_length(msg); i++) {
				struct json_object *msg1 = json_object_array_get_idx(msg, i);
				printf("pubnub subscribe got msg: %s\n", json_object_get_string(msg1));
				process_message(p, sync, msg1);
			}
		}

		json_object_put(msg);
		sleep(1);
	} while (1);


	/* We should never reach this. */

	pubnub_done(p);
	return EXIT_SUCCESS;
}
