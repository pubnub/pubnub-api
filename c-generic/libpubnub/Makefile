CUSTOM_CFLAGS=-Wall -ggdb3 -O3 -std=gnu99 -I. `pkg-config --cflags json libcurl libcrypto libevent` -DDEBUG
LIBS=`pkg-config --libs json libcurl libcrypto libevent`

# TODO: Build a .so library
# TODO: Symbol visibility

LIBOBJS=pubnub.o pubnub-sync.o pubnub-libevent.o crypto.o
OBJS=$(LIBOBJS) example-sync-demo.o example-libevent-demo.o

all: example-sync-demo example-libevent-demo

example-sync-demo: $(LIBOBJS) example-sync-demo.o
	$(call cmd,link)

example-libevent-demo: $(LIBOBJS) example-libevent-demo.o
	$(call cmd,link)

clean:
	rm -f *.o example-sync-demo example-libevent-demo

-include Makefile.lib
