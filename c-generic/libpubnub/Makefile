# Compile using `make XCFLAGS=-DDEBUG` to enable debugging code.
CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 -fPIC -fvisibility=internal -I. `pkg-config --cflags json libcurl libcrypto libevent`
LIBS=`pkg-config --libs json libcurl libcrypto libevent`
SO_LDFLAGS=-fPIC -fvisibility=internal -shared

LIBOBJS=pubnub.o pubnub-sync.o pubnub-libevent.o crypto.o

# This list is just for Makefile.lib's dependency tracking
OBJS=$(LIBOBJS) example-sync-demo.o example-libevent-demo.o

all: libpubnub.so example-sync-demo example-libevent-demo

libpubnub.so: $(LIBOBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(SO_LDFLAGS) -o $@ $^ $(LIBS)

example-sync-demo: example-sync-demo.o ./libpubnub.so
	$(call cmd,link)

example-libevent-demo: example-libevent-demo.o ./libpubnub.so
	$(call cmd,link)

clean:
	rm -f *.o example-sync-demo example-libevent-demo

-include Makefile.lib
