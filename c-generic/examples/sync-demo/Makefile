CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 `pkg-config --cflags libpubnub`
LIBS=`pkg-config --libs libpubnub`

OBJS=example-sync-demo.o

all: example-sync-demo

example-sync-demo: example-sync-demo.o
	$(call cmd,link)

clean:
	rm -f *.o example-sync-demo

install:

-include ../../Makefile.lib
