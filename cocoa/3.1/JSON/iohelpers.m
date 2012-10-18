#include "iohelpers.h"
#include <unistd.h>
#include <time.h>
#include <Foundation/NSStream.h>

#include <Foundation/NSString.h>
#include <Foundation/NSError.h>

// Blocking read with non-blocking [NSInputStream -read:maxLength:].
// Returns number of bytes obtained or -1 in case of error.

int stream_blocking_read( NSInputStream * is, unsigned char * buf, int len )
{
    if ( ! ( is && buf && len > 0 ) )
        return -1;
    
    struct timespec sleep_interval;
    sleep_interval.tv_sec = 0;
    sleep_interval.tv_nsec = 1000; // 1 microsecond
    
    // [iStream hasBytesAvailable] always returns YES ?
    while ( [is hasBytesAvailable] == NO )
        nanosleep( &sleep_interval, 0 );

    int nread = [is read: buf maxLength: len ];

    //debug
    if ( [is streamStatus] == NSStreamStatusError )
    {
        NSLog( @"stream error: %@", [[is streamError] localizedDescription] );
    }
        
    
    while ( nread == -1 && [is streamStatus] != NSStreamStatusError )
    {
        nanosleep( &sleep_interval, 0 );

        // [iStream hasBytesAvailable] always returns YES ?
        while ( [is hasBytesAvailable] == NO )
            nanosleep( &sleep_interval, 0 );

        nread = [is read: buf maxLength: len ];
    }

    //debug
    if ( [is streamStatus] == NSStreamStatusError )
    {
        NSLog( @"stream error: %@", [[is streamError] localizedDescription] );
    }
        
    return nread;
}

// Blocking write with non-blocking [NSOutputStream -write:maxLength].
// Attempts to completely write len bytes to the stream.
// Returns number of bytes actually written or -1 on error.
int stream_writeall( NSOutputStream * os, unsigned char * buf, int len )
{
    struct timespec sleep_interval;
    sleep_interval.tv_sec = 0;
    sleep_interval.tv_nsec = 1000; // 1 microsecond

    while ( [os hasSpaceAvailable] == NO )
        nanosleep( &sleep_interval, 0 );

    int ntot = 0;
    int nwritten;
    while ( ntot < len )
    {
        nwritten = [os write: buf + ntot maxLength: len - ntot];
        if ( nwritten == 0 )
            return ntot;
        else if ( nwritten == -1)
        {
            if ( [os streamStatus] == NSStreamStatusError )
                return -1;
            else
                nanosleep( &sleep_interval, 0 );
        }
        else
        {
            ntot += nwritten;
            if ( ntot >= len )
                break;
        }

        while ( [os hasSpaceAvailable] == NO )
            nanosleep( &sleep_interval, 0 );
    }
    
    return ntot;
}

// Writes required number of bytes from the buffer until all bytes are
// written or the error occurred.
ssize_t writeall( int fd, const unsigned char * buf, size_t len )
{
    int ntot = 0;
    int nwritten;
    while ( ntot < len )
    {
        nwritten = write( fd, buf + ntot, len - ntot);
        if ( nwritten == 0 )
            return ntot;
        else if ( nwritten == -1)
            return -1;
        else
        {
            ntot += nwritten;
            if ( ntot >= len )
                break;
        }
    }
    return ntot;
}
