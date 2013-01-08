# Compile using `make XCFLAGS=-DDEBUG` to enable debugging code.
CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 -I../../libpubnub `pkg-config --cflags json libcurl libcrypto libevent`
LIBS=`pkg-config --libs json libcurl libcrypto libevent`

OBJS=example-libevent-demo.o

all: example-libevent-demo

example-libevent-demo: example-libevent-demo.o ../../libpubnub/libpubnub.so
	$(call cmd,link)

clean:
	rm -f *.o example-libevent-demo

install:

-include ../../Makefile.lib
