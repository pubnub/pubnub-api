CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 `pkg-config --cflags libpubnub`
LIBS=`pkg-config --libs libpubnub`

OBJS=example-libevent-demo.o

all: example-libevent-demo

example-libevent-demo: example-libevent-demo.o
	$(call cmd,link)

clean:
	rm -f *.o example-libevent-demo

install:

-include ../../Makefile.lib
