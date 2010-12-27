#include "ByteStream.h"
#include <fcntl.h>
#include <Foundation/NSString.h>
#include "ByteStreamDelegate.h"

#define DEFAULT_BUFFER_SIZE 4096
//#define DEFAULT_BUFFER_SIZE 64
#define MINIMAL_BUFFER_SIZE 4

#define max( a, b ) ((a) < (b) ? (b) : (a))


// Reads 'count' bytes from stream into buffer. Returns number of bytes read
// which can be less than 'count' if EOF is reached.
unsigned str_getbytes( ByteIStream * s, char * buffer, unsigned count )
{
    unsigned i = 0;
    int ch;

    // Order of evaluation is important.
    // Condition (i < count) comes first to ensure no more than 'count' reads
    while ( i < count && (ch = str_getc( s )) != -1 )
        buffer[i++] = ch;
    return i;
}

// Writes string into stream, returns number of bytes written or -1 on error.
int str_puts( const char * str, ByteOStream * s )
{
    int i = -1;
    while ( str[++i] )
        if ( str_putc( str[i], s ) == -1 )
            return -1;

    return i+1;
}


//-----------------------------------------------------------------------------
// ByteStreamBuffer
//-----------------------------------------------------------------------------

@interface ByteStreamBuffer (Protected)
- (id) initWithCapacity: (unsigned) capa;
@end

@implementation ByteStreamBuffer

- (id) initWithCapacity: (unsigned) capa
{
    if ( (self = [super init]) == nil )
        return 0;
    
    _capa = max( capa, MINIMAL_BUFFER_SIZE);
    _buf = malloc( _capa );
     if ( ! _buf )
     {
         [self release];
         return 0;
     }
     _pos = 0;
     return self;
}

- (void) dealloc
{
    if ( _capa )        // we own _buf
        free( _buf );

    [super dealloc];
}

- (unsigned char *) buffer
{
    return _buf;
}

- (unsigned) bufferCapacity
{
    return _capa;
}

- (int) close
{
    return 0; // always succeeds
}

@end

//-----------------------------------------------------------------------------
// ByteIStream
//-----------------------------------------------------------------------------

@implementation ByteIStream

// Memory stream
- (id) initWithBuffer: (unsigned char *) buf size: (int) len
{
    return [self initWithBuffer: buf size: len makeCopy: NO];
}

// Memory stream
- (id) initWithBuffer: (unsigned char *) buf size: (int) len
             makeCopy: (BOOL) copy
{
    if ( copy )
    {
        if ( (self = [super initWithCapacity: len ]) == nil )
            return 0;

        memcpy( _buf, buf, len );
        _len = len;
    }
    else
    {
        if ( (self = [super init]) == nil )
            return 0;

        _buf = buf;
        _capa = 0;  // do not own
        _len = len;
        _pos = 0;
    }

    _del = [[ByteISDelegateMem alloc] initWithIStream: self];
    if ( ! _del )
    {
        [self release];
        return 0;
    }

    return self;
}

// File descriptor stream
- (id) initWithFD: (int) fd
{
    if ( (self = [super initWithCapacity: DEFAULT_BUFFER_SIZE ]) == nil )
        return 0;
    _len = 0;

    _del = [[ByteISDelegateFD alloc] initWithIStream: self fd: fd];
    if ( ! _del )
    {
        [ self release];
        return 0;
    }

    return self;
}

- (id) initWithFileAtPath: (NSString *) path
{
    return [self initWithFileAtPath: path flags: 0];
}

- (id) initWithFileAtPath: (NSString *) path flags: (int) flags
{
    int fd = open( [path cString], flags | O_RDONLY );
    if ( fd == -1 )
    {
        [self release];
        return 0;
    }

    return [self initWithFD: fd];
}
        

// NSStream stream
- (id) initWithNSIStream: (NSInputStream *) s
{
    if ( (self = [super initWithCapacity: DEFAULT_BUFFER_SIZE ]) == nil )
        return 0;
    _len = 0;

    _del = [[ByteISDelegateStream alloc] initWithIStream: self NSIStream: s];
    if ( ! _del )
    {
        [ self release];
        return 0;
    }

    return self;
}

- (int) close
{
    return [_del close];
}

- (void) dealloc
{
    [_del release];
    [super dealloc];
}

- (unsigned) bufferLength
{
    return _len;
}

@end

//-----------------------------------------------------------------------------
// ByteOStream
//-----------------------------------------------------------------------------

@implementation ByteOStream

// Memory based stream
- (id) init
{
    return [self initWithCapacity: DEFAULT_BUFFER_SIZE];
}

// Memory based stream
- (id) initWithCapacity: (int) size
{
    if ( (self = [super initWithCapacity: DEFAULT_BUFFER_SIZE ]) == nil )
        return 0;

    _del = [[ByteOSDelegateMem alloc] initWithOStream: self];
    if ( ! _del )
    {
        [ self release];
        return 0;
    }

    return self;
}

// File descriptor stream
- (id) initWithFD: (int) fd
{
    if ( (self = [super initWithCapacity: DEFAULT_BUFFER_SIZE ]) == nil )
        return 0;

    _del = [[ByteOSDelegateFD alloc] initWithOStream: self fd: fd];
    if ( ! _del )
    {
        [ self release];
        return 0;
    }

    return self;
}

- (id) initToFileAtPath: (NSString *) path
{
    return [self initToFileAtPath: path flags: 0];
}

- (id) initToFileAtPath: (NSString *) path flags: (int) flags
{
    int fd = open( [path cString], flags | O_WRONLY, 0777 );
    if ( fd == -1 )
    {
        [self release];
        return 0;
    }

    return [self initWithFD: fd];
}

// NSStream based stream
- (id) initWithNSOStream: (NSOutputStream *) s
{
    if ( (self = [super initWithCapacity: DEFAULT_BUFFER_SIZE ]) == nil )
        return 0;

    _del = [[ByteOSDelegateStream alloc] initWithOStream: self NSOStream: s];
    if ( ! _del )
    {
        [ self release];
        return 0;
    }
    
    return self;
}

- (int) close
{
    return [_del close];
}

- (void) dealloc
{
    [_del release];
    [super dealloc];
}

- (unsigned) bufferLength
{
    return _pos;
}

@end
