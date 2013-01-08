# Compile using `make XCFLAGS=-DDEBUG` to enable debugging code.
CUSTOM_CFLAGS=-Wall -ggdb3 -O3
SOFLAGS=-fPIC -fvisibility=internal
SYS_CFLAGS=-std=gnu99 $(SOFLAGS) -I. `pkg-config --cflags json libcurl libcrypto libevent`
LIBS=`pkg-config --libs json libcurl libcrypto libevent`
LDFLAGS=$(SOFLAGS) -shared

OBJS=pubnub.o pubnub-sync.o pubnub-libevent.o crypto.o

all: libpubnub.so

libpubnub.so: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f *.o libpubnub.so

install:
	$(INSTALL) -D -m 0644 pubnub.h $(DESTDIR)$(INCDIR)/pubnub.h
	$(INSTALL) -D -m 0644 pubnub-sync.h $(DESTDIR)$(INCDIR)/pubnub-sync.h
	$(INSTALL) -D -m 0644 pubnub-libevent.h $(DESTDIR)$(INCDIR)/pubnub-libevent.h
	$(INSTALL) -D -m 0755 libpubnub.so $(DESTDIR)$(LIBDIR)/libpubnub.so
	ldconfig

-include ../Makefile.lib
