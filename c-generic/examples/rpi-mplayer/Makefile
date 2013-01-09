CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 `pkg-config --cflags libpubnub`
LIBS=`pkg-config --libs libpubnub`

OBJS=pubnub-rpi-mplayer.o

all: pubnub-rpi-mplayer

pubnub-rpi-mplayer: pubnub-rpi-mplayer.o
	$(call cmd,link)

clean:
	rm -f *.o pubnub-rpi-mplayer

install:

-include ../../Makefile.lib
