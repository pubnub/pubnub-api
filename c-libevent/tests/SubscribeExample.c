#include<stdio.h>
#include <string.h>
#include "../pubnub/Pubnub.h"

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
    // initialize Pubnub state
    Pubnub_overload1("demo", "demo", "demo", "demo", true);

    // call subscribe function
    subscribe(&args);

    return 0;
}
