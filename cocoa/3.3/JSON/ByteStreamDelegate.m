#include "ByteStreamDelegate.h"
#include "iohelpers.h"
#include <Foundation/NSStream.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>

//#include <Foundation/NSString.h> // Debug

#define F_DEL_EOF   0x1
#define F_DEL_BAD   0x2

//-----------------------------------------------------------------------------
// Memory
//-----------------------------------------------------------------------------

@implementation ByteISDelegateMem

- (id) initWithIStream: (ByteIStream *) s
{
    if ( (self = [super init]) != nil )
    {
        _s = s;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (BOOL) eof
{
    return _s->_pos >= _s->_len;
}

- (int) underflow
{
    return -1;  // fail
}

- (int) close
{
    return 0;   // success
}

@end

@implementation ByteOSDelegateMem

- (id) initWithOStream: (ByteOStream *) s
{
    if ( (self = [super init]) != nil )
    {
        _s = s;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (int) close
{
    return 0;   // success
}

- (int) flush
{
    return 0;   // success
}

- (int) overflow: (unsigned char) ch
{
    // double the buffer capacity
    if ( ! _s->_capa )
        _s->_capa = 2;

    _s->_capa *= 2;
    if ( (_s->_buf = realloc( _s->_buf, _s->_capa )) == 0 )
        return -1;
    return _s->_buf[ _s->_pos++ ] = ch;
}

@end

//-----------------------------------------------------------------------------
// File descriptor
//-----------------------------------------------------------------------------

@implementation ByteISDelegateFD

- (id) initWithIStream: (ByteIStream *) s fd: (int) fd
{
    if ( (self = [super init]) != nil )
    {
        _s = s;
        _fd = fd;
        _flags = 0;
    }
    
    return self;
}

- (void) dealloc
{
    [self close];
    [super dealloc];
}

- (BOOL) eof
{
    return _flags & F_DEL_EOF;
}

- (int) close
{
    int ret = close(_fd);
    if ( ret == -1 )
        if ( errno == EBADF )
            ret = errno = 0;
    return ret;
}

- (int) underflow
{
    if ( _flags & F_DEL_EOF || _flags & F_DEL_BAD )
        return -1;
    
    // Reset parent's position
    _s->_pos = 0;
    _s->_len = 0;   // if unchanged, next getc() will cause underflow

    // the read() call blocks
    int nread = read( _fd, _s->_buf, _s->_capa );
    if ( nread == -1 )
    {
        _flags |= F_DEL_BAD;
        return -1;
    }
    else if (nread == 0)
    {
        _flags |= F_DEL_EOF;
        return -1;
    }
    else
    {
        _s->_len = nread;
    }

    return _s->_buf[0];
}
@end

@implementation ByteOSDelegateFD

- (id) initWithOStream: (ByteOStream *) s fd: (int) fd
{
    if ( (self = [super init]) != nil )
    {
        _s = s;
        _fd = fd;
        _flags = 0;
    }
    return self;
}

- (void) dealloc
{
    [self close];
    [super dealloc];
}

- (int) close
{
    int flush_status = [self flush];
    int close_status = close(_fd);
    if ( close_status == -1 )
        if ( errno == EBADF )
            close_status = errno = 0;
    
    return flush_status ? flush_status : close_status;
}

- (int) flush
{
    if ( _flags & F_DEL_BAD )
        return -1;
    
    // Write characters from position 0 up to _pos.
    if ( _s->_pos > 0 )
    {
        // Blocking write
        ssize_t nwritten = writeall( _fd, _s->_buf, _s->_pos );
        if ( nwritten != _s->_pos )
        {
            _flags |= F_DEL_BAD;
            _s->_pos = _s->_capa; // next putc() will cause overflow
            return -1;
        }
        _s->_pos = 0;
    }
    return 0;
}

- (int) overflow: (unsigned char) ch
{
    // Inefficient, should we get an IMP pointer?
    if ( [self flush] == -1 )
        return -1;

    // Place input character at position 0 and return that character.
    return _s->_buf[ _s->_pos++ ] = ch;
}

@end

//-----------------------------------------------------------------------------
// NSStream
//-----------------------------------------------------------------------------

static struct timespec delay = { 0, 100000 }; // 100 microseconds

@implementation ByteISDelegateStream

- (id) initWithIStream: (ByteIStream *) s NSIStream: (NSInputStream *) iStream
{
    if ( (self = [super init]) != nil )
    {
        _s = s;
        _iStream = iStream;
        [_iStream retain];
        _flags = 0;

        // Open the stream if not yet opened.
        if ( _iStream && [_iStream streamStatus] == NSStreamStatusNotOpen )
        {
            [_iStream open];

            // BUG: polling instead of arranging to get notification
            int cnt = 0;
            while ( [_iStream streamStatus] != NSStreamStatusOpen && cnt++ < 10)
                nanosleep( &delay, 0 );
            if ( [_iStream streamStatus] != NSStreamStatusOpen )
            {
                // open failed
                [self release];
                return nil;
            }
        }
    }
    
    return self;
}

- (void) dealloc
{
    [self close];
    [_iStream release];
    [super dealloc];
}

- (BOOL) eof
{
    return _flags & F_DEL_EOF;
}

- (int) close
{
    NSStreamStatus status = [_iStream streamStatus];
    if ( status != NSStreamStatusNotOpen && status != NSStreamStatusClosed )
        [_iStream close];
    return 0;
}

- (int) underflow
{
    if ( _flags & F_DEL_EOF || _flags & F_DEL_BAD )
        return -1;
    
    // Reset parent's position
    _s->_pos = 0;
    _s->_len = 0;   // if unchanged, next getc() will cause underflow

    // the read call blocks
    int nread = stream_blocking_read( _iStream, _s->_buf, _s->_capa );
    if ( nread == -1 )
    {
        _flags |= F_DEL_BAD;
        return -1;
    }
    else if (nread == 0)
    {
        _flags |= F_DEL_EOF;
        return -1;
    }
    else
    {
        _s->_len = nread;
    }

    return _s->_buf[0];
}

@end

@implementation  ByteOSDelegateStream

- (id) initWithOStream: (ByteOStream *) s NSOStream: (NSOutputStream *) oStream
{
    if ( (self = [super init]) != nil )
    {
        _s = s;
        _oStream = oStream;
        [_oStream retain];
        _flags = 0;

        // Open the stream if not yet opened
        if ([_oStream streamStatus] == NSStreamStatusNotOpen )
        {
            [_oStream open];

            // BUG: polling instead of arranging to get notification
            int cnt = 0;
            while ( [_oStream streamStatus] != NSStreamStatusOpen && cnt++ < 10)
                nanosleep( &delay, 0 );
            if ( [_oStream streamStatus] != NSStreamStatusOpen )
            {
                // open failed
                [self release];
                return nil;
            }
        }
    }

    return self;
}

- (void) dealloc
{
    [self close];
    [_oStream release];
    [super dealloc];
}

- (int) close
{
    int flush_status = [self flush];

    NSStreamStatus status = [_oStream streamStatus];
    if ( status != NSStreamStatusNotOpen && status != NSStreamStatusClosed )
        [_oStream close];
    return flush_status;
}

- (int) flush
{
    if ( _flags & F_DEL_BAD )
        return -1;
    
    // Write characters from position 0 up to _pos.
    if ( _s->_pos > 0 )
    {
        // Blocking write
        int nwritten = stream_writeall( _oStream, _s->_buf, _s->_pos );
        if ( nwritten != _s->_pos )
        {
            _flags |= F_DEL_BAD;
            _s->_pos = _s->_capa; // next putc() will cause overflow
            return -1;
        }
        _s->_pos = 0;
    }
    return 0;
}

- (int) overflow: (unsigned char) ch
{
    // Inefficient, should we get an IMP pointer?
    if ( [self flush] == -1 )
        return -1;
    
    // Place input character at position 0 and return that character.
    return _s->_buf[ _s->_pos++ ] = ch;
}

@end
