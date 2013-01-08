# Compile using `make XCFLAGS=-DDEBUG` to enable debugging code.

PREFIX=/usr/local
LIBDIR=$(PREFIX)/lib
INCDIR=$(PREFIX)/include
export PREFIX LIBDIR INCDIR

# libpubnub must come first!
SUBDIRS=libpubnub examples/sync-demo examples/libevent-demo

all: all-recursive

clean: clean-recursive

install: install-recursive

-include Makefile.lib
