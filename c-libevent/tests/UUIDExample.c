#include <stdio.h>
#include <string.h>
#include "../pubnub/Pubnub.h"

int main() {

#ifdef _WIN32
    WSADATA WSAData;
    WSAStartup(0x101, &WSAData);
#else
    if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
    return (1);
#endif

    // initialize Pubnub state
    Pubnub_overload1("demo", "demo", "", "", false);//[Cipher key is Optional]

    printf("UUID:::%s", uuid());

    return 0;
}
