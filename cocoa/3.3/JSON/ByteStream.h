#ifndef _INCLUDED_ByteStream_h
#define _INCLUDED_ByteStream_h

// ByteIStream, ByteOStream - bufferred input and output classes
// emulating stream of bytes. They provide subset of FILE stream
// functionality from standard C library.

#include <Foundation/NSObject.h>

//-----------------------------------------------------------------------------
// Delegate protocols.
//-----------------------------------------------------------------------------

@protocol ByteISDelegate
// Get new data from the data source. Return first new character or -1 if
// operation failed or end of file encountered. Do not advance the position.
- (int) underflow;

// Return YES if the stream is at EOF
- (BOOL) eof;

// Close data source. Returns 0 on success or -1 on error
- (int) close;
@end

@protocol ByteOSDelegate
// Flush the buffer into the data sink. Return 0 on success and -1 on failure.
- (int) flush;

// Move some or all data to the data sink, then put ch into buffer.
// Return that character on success or -1 if data move failed.
// Current implementations try to move all data, like flush does.
- (int) overflow: (unsigned char) ch;

// Flush data and close data sink. Return 0 on success or -1 on error
- (int) close;
@end


//-----------------------------------------------------------------------------
// ByteStreamBuffer - superclass for input and output streams
//-----------------------------------------------------------------------------

@interface ByteStreamBuffer : NSObject
{
@public    
    unsigned char *     _buf;   // buffer
    unsigned            _capa;  // size of buffer, 0 means _buf is not owned
    unsigned            _pos;   // current input or output position 
}

- (unsigned char *) buffer;
- (unsigned) bufferCapacity;

- (int) close;

@end

//-----------------------------------------------------------------------------
// Input byte stream.
//-----------------------------------------------------------------------------

@class NSInputStream;

@interface ByteIStream: ByteStreamBuffer
{
@public    
    id <ByteISDelegate, NSObject> _del;
    unsigned            _len;   // length of data within buffer
}

// Memory stream
- (id) initWithBuffer: (unsigned char *) buffer size: (int) len;
- (id) initWithBuffer: (unsigned char *) buffer size: (int) len
             makeCopy: (BOOL) copy;

// File descriptor stream
- (id) initWithFD: (int) fd;
- (id) initWithFileAtPath: (NSString *) path;
- (id) initWithFileAtPath: (NSString *) path flags: (int) flags;

// NSStream stream
- (id) initWithNSIStream: (NSInputStream *) s;

- (int) close;

- (unsigned) bufferLength;

@end

//-----------------------------------------------------------------------------
// Output byte stream.
//-----------------------------------------------------------------------------

@class NSOutputStream;

@interface ByteOStream: ByteStreamBuffer
{
@public    
    id <ByteOSDelegate, NSObject> _del;
}

// Memory stream
- (id) init;
- (id) initWithCapacity: (int) capa;

// File descriptor stream
- (id) initWithFD: (int) fd;
- (id) initToFileAtPath: (NSString *) path;
- (id) initToFileAtPath: (NSString *) path flags: (int) flags;

// NSStream based stream
- (id) initWithNSOStream: (NSOutputStream *) s;

- (int) close;

- (unsigned) bufferLength;

@end


//-----------------------------------------------------------------------------
// Input functions.
//-----------------------------------------------------------------------------


inline static BOOL str_eof( ByteIStream * s )
{
    return [s->_del eof];
}

// Returns next byte and does not advance the current position,
// returns -1 on eof or error.
inline static int str_peekc( ByteIStream * s )
{
    return (s->_pos < s->_len) ? s->_buf[s->_pos] : [s->_del underflow];
}

// Return next byte and advance the current position,
// returns -1 on eof or error.
inline static int str_getc( ByteIStream * s )
{
    int ch = str_peekc( s );
    if ( ch != -1 )
        ++s->_pos;
    return ch;
}

// Move current position back and inserts given byte at it.
// Currently guaranteed to work only after str_getc().
inline static int str_ungetc( unsigned char c, ByteIStream * s )
{
  return (s->_pos > 0) ? (s->_buf[--s->_pos] = c) : -1;
}

// Reads 'count' bytes from stream into buffer. Returns number of bytes read
// which can be less than 'count' if EOF is reached.
unsigned str_getbytes( ByteIStream * s, char * buffer, unsigned count );


//-----------------------------------------------------------------------------
// Output functions.
//-----------------------------------------------------------------------------

// Put character c into stream s. Returns that character or -1 on error.
inline static int str_putc( unsigned char c, ByteOStream * s )
{
    return (s->_pos < s->_capa) ?
        (s->_buf[s->_pos++] = c) : [s->_del overflow: c];
}

// Flushes the buffer into the data sink. Returns 0 on success, -1 on failure.
inline static int str_flush( ByteOStream * s )
{
    return [s->_del flush];
}

// Writes string into stream, returns number of bytes written or -1 on error.
int str_puts( const char * str, ByteOStream * s );

inline static int str_close( ByteStreamBuffer * s )
{
    return [s close];
}


#endif // _INCLUDED_ByteStream_h
