CUSTOM_CFLAGS=-Wall -ggdb3 -O3 -std=gnu99 -I. `pkg-config --cflags json` `pkg-config --cflags libcurl` -DDEBUG
LIBS=`pkg-config --libs json` `pkg-config --libs libcurl`

# TODO: Build a .so library
# TODO: Symbol visibility

LIBOBJS=pubnub.o pubnub-sync.o
OBJS=$(LIBOBJS) example-sync-demo.o

all: example-sync-demo

example-sync-demo: $(LIBOBJS) example-sync-demo.o
	$(call cmd,link)

clean:
	rm -f *.o example-sync-demo

-include Makefile.lib
