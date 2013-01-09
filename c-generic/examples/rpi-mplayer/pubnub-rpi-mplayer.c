#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include <json.h>

#include "pubnub.h"
#include "pubnub-sync.h"


/* See README.md for a brief usage and functional description. */


/* ID identifying this particular RPi. If not passed as an argument,
 * randomly generated on each program run. */
int rpi_id;

/* Media player to use. */
char *mplayer_cmd = "mplayer"; // omxplayer is a good alternative


/* Status-determining variables. */

/* When doing an action based on mplayer_pid value, we must be careful
 * not to trigger a race condition. For example, a simple code
 * 	if (!mplayer_pid) return;
 * 	kill(mplayer_pid, SIGKILL);
 * may sometimes make us _suicide_ - it's perfectly possible to receive
 * a SIGCHLD that will reset mplayer_pid to zero inbetween of these two
 * statements. An easy solution is to copy the value over to a local
 * variable before doing a "transaction" on it. */
volatile pid_t mplayer_pid = 0;

char *mplayer_last_file = NULL;


void
arg_help(char *argv0)
{
	fprintf(stderr, "Usage: %s [-i RPI_ID] [-m MPLAYER_CMD]\n", argv0);
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
handle_sigchld(int sig)
{
	mplayer_pid = 0;
}

int
play_worker(const char *file)
{
	/* XXX: Spawning processes may be hard work; cleaning up
	 * signal sets, closing leaked file descriptors, and so on.
	 * In our case, neither is relevant, luckily. */

	if (execlp(mplayer_cmd, mplayer_cmd, file, NULL) < 0) {
		perror("execlp");
		exit(EXIT_FAILURE);
	}

	// should never reach here
	return 0;
}


void
send_status(struct pubnub *p, struct pubnub_sync *sync)
{
	json_object *msg = json_object_new_object();
	json_object_object_add(msg, "id", json_object_new_int(rpi_id));

	pid_t mplayer_pid_now = mplayer_pid; // see mplayer_pid decl.
	json_object_object_add(msg, "status", json_object_new_string(mplayer_pid_now ? "playing" : "idle"));
	if (mplayer_pid_now)
		json_object_object_add(msg, "file", json_object_new_string(mplayer_last_file));

	publish(p, sync, "rpi_mplayer_status", msg);
}

void stop(void);

void
play(const char *file)
{
	/* If we are already playing, stop that. */
	if (mplayer_pid)
		stop();

	/* Update last_file info. */
	if (mplayer_last_file)
		free(mplayer_last_file);
	mplayer_last_file = strdup(file);

	/* Spawn media player on the background. */
	pid_t pid = (mplayer_pid = fork());
	if (pid < 0) {
		perror("fork");
		exit(EXIT_FAILURE);
	}
	if (pid == 0) {
		/* This is the background process. */
		exit(play_worker(file));
	}
}

void
stop(void)
{
	pid_t mplayer_pid_now = mplayer_pid; // see mplayer_pid decl.
	if (!mplayer_pid_now)
		return;
	kill(mplayer_pid_now, SIGTERM);
	wait(NULL);
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

	/* Do the right thing based on the "cmd" field. */

	json_object *cmd = json_object_object_get(msg, "cmd");
	if (!cmd || !json_object_is_type(cmd, json_type_string))
		return;
	const char *scmd = json_object_get_string(cmd);

	if (!strcmp(scmd, "ping")) {
		send_status(p, sync);

	} else if (!strcmp(scmd, "play")) {
		json_object *file = json_object_object_get(msg, "file");
		if (!file || !json_object_is_type(file, json_type_string))
			return;
		const char *sfile = json_object_get_string(file);
		if (strstr(sfile, "../"))
			return; // basic sanity check
		play(sfile);
		send_status(p, sync);

	} else if (!strcmp(scmd, "stop")) {
		stop();
		send_status(p, sync);
	}
}

int
main(int argc, char *argv[])
{
	/* Parse options. */

	/* Default: */
	srand(time(NULL));
	rpi_id = rand();

	int opt;
	while ((opt = getopt(argc, argv, "i:m:")) != -1) {
		switch (opt) {
		case 'i':
			rpi_id = atoi(optarg);
			break;
		case 'm':
			mplayer_cmd = optarg;
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


	/* Set up "playing finished" notification. */

	signal(SIGCHLD, handle_sigchld);


	/* Initialize PubNub. */

	struct pubnub_sync *sync = pubnub_sync_init();
	struct pubnub *p = pubnub_init("demo", "demo", NULL, NULL, NULL, &pubnub_sync_callbacks, sync);


	/* Advertise. */

	send_status(p, sync);


	/* Command loop. */

	do {
		pubnub_subscribe(p, "rpi_mplayer_cmd", 300, NULL, NULL);

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
