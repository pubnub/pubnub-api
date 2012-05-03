#include <stdio.h>
#include <string.h>
#include "../pubnub/Pubnub.h"
#include "json.h"


static void publish_callback_json_object(json_object *obj) {
    printf("\n%s",json_object_to_json_string(obj));
}

static void publish_callback_json_array(json_object *obj) {
    printf("\n%s",json_object_to_json_string(obj));
}

int main() {
#ifdef _WIN32
    WSADATA WSAData;
    WSAStartup(0x101, &WSAData);
#else
    if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
    return (1);
#endif

    // initialize Pubnub state
    Pubnub_overload1("demo", "demo", "demo", "demo", true);


    // publish json_object
    json_object * my_object = json_object_new_object();
    json_object_object_add(my_object, "some_val", json_object_new_string("Hello"));
    struct struct_publish args1 = { .channel = "hello_world", .message = my_object,
                .cb = publish_callback_json_object, .type = 3 };
    publish(&args1);

    // publish json_object array
    json_object *my_array = json_object_new_array();
    json_object_array_add(my_array, json_object_new_string("hello"));
    struct struct_publish args2 = { .channel = "hello_world1", .message = my_array, .cb = publish_callback_json_array, .type = 2 };
    //publish(&args2);

    //getch();
    return 0;
}
