#ifndef _INCLUDED_iohelpers_h
#define _INCLUDED_iohelpers_h

#include <unistd.h>

@class NSInputStream;
@class NSOutputStream;

int stream_blocking_read( NSInputStream * is, unsigned char * buf, int len );
int stream_writeall( NSOutputStream * os, unsigned char * buf, int len );
ssize_t writeall( int fd, const unsigned char * buf, size_t len );

#endif // _INCLUDED_iohelpers_h
