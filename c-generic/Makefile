# Compile using `make XCFLAGS=-DDEBUG` to enable debugging code.

PREFIX=/usr/local
LIBDIR=$(PREFIX)/lib
INCDIR=$(PREFIX)/include
export PREFIX LIBDIR INCDIR

# We ignore examples/, they shall not be built by default and
# their makefiles depend on libpubnub already being installed anyway.
SUBDIRS=libpubnub

all: all-recursive

clean: clean-recursive

install: install-recursive

-include Makefile.lib
