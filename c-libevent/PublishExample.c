#include <stdio.h>
#include <string.h>
#include "Pubnub.h"
#include "json.h"

static void publish_callback(json_object *obj) {
	write(1, json_object_to_json_string(obj),
			strlen(json_object_to_json_string(obj)));
}

int main() {
#ifdef _WIN32
	WSADATA WSAData;
	WSAStartup(0x101, &WSAData);
#else
	if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
	return (1);
#endif

	// json_object test
	json_object * my_object = json_object_new_object();
	json_object_object_add(my_object, "abc", json_object_new_int(12));
	json_object_object_add(my_object, "foo", json_object_new_string("bar"));

	struct struct_publish args = { .channel = "hello_world", .message =
			my_object, .cb = publish_callback, .type = 3 };

	// string test
	struct struct_publish args1 = { .channel = "hello_world", .message =
			"Hello world", .cb = publish_callback, .type = 1 };

	// json_object array test
	json_object *my_array = json_object_new_array();
	json_object_array_add(my_array, json_object_new_int(1));
	json_object_array_add(my_array, json_object_new_int(2));
	json_object_array_add(my_array, json_object_new_int(3));

	struct struct_publish args2 = { .channel = "hello_world", .message =
			my_array, .cb = publish_callback, .type = 2 };

	// initialize Pubnub state
	Pubnub_overload1("demo", "demo", "demo", "0123456789012345", true);

	// publish json_object
	publish(&args);

	// publish string
	publish(&args1);

	// publish json_object array
	publish(&args2);

	return 0;
}
