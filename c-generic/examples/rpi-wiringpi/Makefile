CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SYS_CFLAGS=-std=gnu99 `pkg-config --cflags libpubnub`
LIBS=`pkg-config --libs libpubnub` -lwiringPi

OBJS=pubnub-rpi-wiringpi.o

all: pubnub-rpi-wiringpi

pubnub-rpi-wiringpi: pubnub-rpi-wiringpi.o
	$(call cmd,link)

clean:
	rm -f *.o pubnub-rpi-wiringpi

install:

-include ../../Makefile.lib
