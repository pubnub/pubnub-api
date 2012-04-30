#include <stdio.h>
#include <string.h>
#include "Pubnub.h"

int main() {

#ifdef _WIN32
	WSADATA WSAData;
	WSAStartup(0x101, &WSAData);
#else
	if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
	return (1);
#endif

	// call constructor with cipher key
	Pubnub_overload1("demo", "demo", "", "", false);

	printf("UUID:::%s", uuid());

	return 0;
}
