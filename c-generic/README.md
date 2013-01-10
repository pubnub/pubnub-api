PubNub C Library
================

The generic PubNub C library provides an elegant, easy-to-use but
flexible API for C programs to use the PubNub cloud messaging service.

The library supports multiple event notification backends - this
allows it to be used in a synchronous manner (in simple C programs),
asynchronously with the libevent library, or integrated with any other
event loop as the user can provide their own set of callbacks.

The library should be fully thread safe and signal safe. The code currently
covers only POSIX systems and has not been tested on Windows yet.

Synopsis
--------

Build your program with compile flags as provided by
``pkg-config --cflags libpubnub'' and build flags based on
``pkg-config --libs libpubnub''.

	#include <json.h>
	#include <pubnub.h>
	#include <pubnub-sync.h>

	struct pubnub_sync *sync = pubnub_sync_init();
	struct pubnub *p = pubnub_init("demo", "demo", NULL, NULL, NULL,
			 &pubnub_sync_callbacks, sync);

	pubnub_publish(p, "my_channel", json_object, 0, NULL, NULL);

	do {
		pubnub_subscribe(p, "my_channel", 300, NULL, NULL);
		if (pubnub_sync_last_result(sync) != PNR_OK)
			continue;
		struct json_object *msg = pubnub_sync_last_response(sync);
		for (int i = 0; i < json_object_array_length(msg); i++) {
			json_object *msg1 = json_object_array_get_idx(msg, i);
			printf("received: %s\n", json_object_get_string(msg1));
		}
	} while (1);

See the provided examples for full error handling and more desriptive code.

Installation
------------

Libraries libevent, libjson, libcurl and OpenSSL are required to build
libpubnub. Since we are compiling the library, it is not enough to have
the libraries installed, you will also need header files (usually distributed
as development packages). On Debian-like systems, use the command:

	sudo apt-get install libevent-dev libjson0-dev libcurl4-openssl-dev libssl-dev

Use the command

	make

to build the library. In case of errors, verify that you really have
all the libraries installed.

By default, the library will be installed to /usr/local. To change
the install location, edit the PREFIX line in ``Makefile'', but you will
need to make arrangements for the ld.so dynamic linker to be able to
find libpubnub in your chosen location (e.g. adding the directory to
/etc/ld.so.conf or using $LD_LIBRARY_PATH environment variable).

After you have made sure the install location matches your expectations
(if you aren't sure, the /usr/local default is a fine choice), run

	sudo make install

and enjoy libpubnub!

API Description
---------------

This section of the documentation is still TODO. In the meantime, please refer
to the header files (pubnub.h, pubnub-sync.h, pubnub-libevent.h) which are
heavily commented (in general).

Examples
--------

A set of examples to show-case basic and recommended usage of the library
can be found in the examples/ directory. Beginners should first examine
the simplest ``sync-demo'' example.

The examples can be built and run after the library itself is installed.
A simple ``make'' command should suffice to build the binary. Refer to the
local README.md files regarding any special details regarding each example.
