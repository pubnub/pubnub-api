# Compile using `make XCFLAGS=-DDEBUG` to enable debugging code.
CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 -I../../libpubnub `pkg-config --cflags json libcurl libcrypto libevent`
LIBS=`pkg-config --libs json libcurl libcrypto libevent`

OBJS=example-sync-demo.o

all: example-sync-demo

example-sync-demo: example-sync-demo.o ../../libpubnub/libpubnub.so
	$(call cmd,link)

clean:
	rm -f *.o example-sync-demo

-include ../../Makefile.lib
