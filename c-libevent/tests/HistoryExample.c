/*
 *
 * Example of how to use history function of this library
 *
 * */

#include<stdio.h>
#include <string.h>
#include "../pubnub/Pubnub.h"

// create callback method used in history structure

static void history_callback(json_object *obj) {
    printf("\n Message(s)::%s", json_object_to_json_string(obj));
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
    // create a structure instance to pass as an argument to history function
    struct struct_history args = { .channel = "hello_world", .limit = 2, .cb = history_callback };

    // initialize Pubnub state
    Pubnub_overload1("demo", "demo", "demo", "", false);//[Cipher key is Optional]

    // call history function
    history(&args);

    return 0;
}
