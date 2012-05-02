//#include<stdio.h>
//#include <string.h>
//#include "../pubnub/Pubnub.h"
//
//static void history_callback(json_object *obj) {
//
//	write(1, json_object_to_json_string(obj),
//			strlen(json_object_to_json_string(obj)));
//}
//
//int main() {
//
//#ifdef _WIN32
//	WSADATA WSAData;
//	WSAStartup(0x101, &WSAData);
//#else
//	if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
//	return (1);
//#endif
//	struct struct_history args = { .channel = "hello_world1", .limit = 2, .cb =
//			history_callback };
//	// initialize Pubnub state
//	Pubnub_overload1("demo", "demo", "demo", "demo", false);
//
//	// call history function
//	history(&args);
//
//	return 0;
//}
