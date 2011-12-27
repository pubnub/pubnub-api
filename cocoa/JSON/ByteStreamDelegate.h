#ifndef _INCLUDED_ByteStreamDelegate_h
#define _INCLUDED_ByteStreamDelegate_h

#include "ByteStream.h"

@class NSInputStream;
@class NSOutputStream;

//-----------------------------------------------------------------------------
// Input stream delegate - memory.
//-----------------------------------------------------------------------------

@interface ByteISDelegateMem : NSObject <ByteISDelegate>
{
    ByteIStream * _s;
}

- (id) initWithIStream: (ByteIStream *) s;
- (void) dealloc;

- (int) underflow;
- (BOOL) eof;
- (int) close;
@end

//-----------------------------------------------------------------------------
// Output stream delegate - memory
//-----------------------------------------------------------------------------

@interface ByteOSDelegateMem : NSObject <ByteOSDelegate>
{
    ByteOStream * _s;
}

- (id) initWithOStream: (ByteOStream *) s;
- (void) dealloc;

- (int) flush;
- (int) overflow: (unsigned char) ch;
- (int) close;
@end

//-----------------------------------------------------------------------------
// Input stream delegate - file descriptor
//-----------------------------------------------------------------------------

@interface ByteISDelegateFD : NSObject <ByteISDelegate>
{
    ByteIStream *   _s;
    int             _fd;
    unsigned        _flags;
}

- (id) initWithIStream: (ByteIStream *) s fd: (int) fd;
- (void) dealloc;

- (int) underflow;
- (BOOL) eof;
- (int) close;
@end

//-----------------------------------------------------------------------------
// Output stream delegate - file descriptor
//-----------------------------------------------------------------------------

@interface ByteOSDelegateFD : NSObject <ByteOSDelegate>
{
    ByteOStream *   _s;
    int             _fd;
    unsigned        _flags;
}

- (id) initWithOStream: (ByteOStream *) s fd: (int) fd;
- (void) dealloc;

- (int) flush;
- (int) overflow: (unsigned char) ch;
- (int) close;
@end

//-----------------------------------------------------------------------------
// Input stream delegate - NSInputStream
//-----------------------------------------------------------------------------

@interface ByteISDelegateStream : NSObject <ByteISDelegate>
{
    ByteIStream *   _s;
    NSInputStream * _iStream;
    unsigned        _flags;
}

- (id) initWithIStream: (ByteIStream *) s NSIStream: (NSInputStream *) iStream;
- (void) dealloc;

- (int) underflow;
- (BOOL) eof;
- (int) close;
@end


//-----------------------------------------------------------------------------
// Output stream delegate - NSOutputStream
//-----------------------------------------------------------------------------

@interface ByteOSDelegateStream : NSObject <ByteOSDelegate>
{
    ByteOStream *       _s;
    NSOutputStream *    _oStream;
    unsigned            _flags;
}

- (id) initWithOStream: (ByteOStream *) s NSOStream: (NSOutputStream *) oStream;
- (void) dealloc;

- (int) flush;
- (int) overflow: (unsigned char) ch;
- (int) close;
@end

#endif // _INCLUDED_ByteStreamDelegate_h
