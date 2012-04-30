#include<stdio.h>
#include <string.h>
#include "Pubnub.h"

static void subscribe_callback(json_object *obj) {
	printf("\n Message::%s", json_object_to_json_string(obj));
	string str = strconcat(json_object_to_json_string(obj), "\n");
	write(1, str, strlen(str));
}

int main() {

#ifdef _WIN32
	WSADATA WSAData;
	WSAStartup(0x101, &WSAData);
#else
	if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
	return (1);
#endif

	struct struct_subscribe args = { .channel = "hello_world", .cb = subscribe_callback };
	// call constructor with cipher key
	Pubnub_overload1("demo", "demo", "", "", false);

	//call subscribe() method
	subscribe(&args);

	return 0;
}
