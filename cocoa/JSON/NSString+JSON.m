#include "JSONExtensions.h"
#include <Foundation/NSString.h>
#include <Foundation/NSZone.h>
#include "ByteStream.h"
#include "streamutils.h"
#include "jsunicode.h"

static BOOL s_preferUtf8ForWrite = YES;

@implementation NSString (JSON)

+ (BOOL) preferUtf8ForWritingJSON
{
    return s_preferUtf8ForWrite;
}

+ (void) setPreferUtf8ForWritingJSON: (BOOL) val
{
    s_preferUtf8ForWrite = val;
}

- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    int capa = 32;
    unsigned char * buffer = (unsigned char *)NSZoneMalloc([self zone], capa);
    if ( ! buffer )
    {
        if ( err )
            *err = [NSString stringWithFormat: @"NSZoneMalloc() failed"];
        goto failure;
    }

    
    int i = 0;  // position for writing in buffer

    int uChar4Hex = -1; // differs from -1 if we have 4hex representation
    int charLength = 1; // may differ from 1 if we have 4hex representation

    // First character must be '"'
    int ch = peek_nonblank_char( str );

    // Return 0 if the stream ended
    if ( ch == -1 && str_eof( str ) )
    {
        [self release];
        return 0;
    }

    if ( ch != '"' )
    {
        if ( err )
            *err = [NSString stringWithFormat: @"first char is not \""];
        goto failure;
    }

    str_getc( str ); // eat leading '"'

    BOOL escape = NO;
    BOOL escaped = NO;
    while ( (ch = str_getc( str )) != -1 )
    {
        escape = (ch == '\\' && escape == NO);
        if ( escape )
        {
            escaped = YES;
            continue;
        }

        if ( !escaped && ch == '"' )
        {
            // unescaped '"' ends the string
            goto success;
        }

        if ( escaped )
        {
            escaped = NO;
            switch ( ch )
            {
                case 'n': ch = '\n'; break;
                case 't': ch = '\t'; break;
                case 'r': ch = '\r'; break;
                case 'b': ch = '\b'; break;
                case 'f': ch = '\f'; break;
                case 'u':
                {
                    uChar4Hex = get4hex( str );
                    if ( uChar4Hex == -1 )
                    {
                        if ( err )
                            [NSString stringWithFormat: @"can't read 4 hex"];
                        goto failure;
                    }
                    charLength = utf8length( uChar4Hex );
                }
                break;
            }
        }

        // Enlarge buffer if needed
        if ( i + charLength > capa )
        {
            capa *= 2;
            buffer = (unsigned char *)NSZoneRealloc([self zone], buffer, capa);
            if ( ! buffer )
            {
                if ( err )
                    *err = [NSString stringWithFormat: @"NSZoneRealloc() failed"];
                goto failure;   // cannot allocate memory
            }
        }

        if ( uChar4Hex != -1 )
        {
            i += intToUtf8( uChar4Hex, buffer + i );

            // Restore these values assuming that 4hex is rare and
            // we will seldom hit this branch.
            uChar4Hex = -1;
            charLength = 1;
        }
        else
        {
            buffer[i++] = (unsigned char)ch;
        }
    }

    // If we got here we had seen EOF before ending '"'
    if ( err )
        *err = [NSString stringWithFormat: @"no ending \""];

    
 failure:
    NSZoneFree( [self zone], buffer );
    [self release];
    return 0;
    
 success:    
    return
        [self initWithBytesNoCopy: buffer
              length: i
              encoding: NSUTF8StringEncoding
              freeWhenDone: YES
         ];
}


- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) unused
{
    unsigned len = [self length];
    unsigned i;
    int uChar;
    int ret;

    if ( ! str_putc( '"', str ) )
        return NO;

    for ( i=0; i < len; ++i )
    {
        uChar = [self characterAtIndex: i];
        if ( uChar < 0x20 )
        {
            if ( ! str_putc( '\\', str ) )
                return NO;

            switch ( uChar )
            {
                case '\b': ret = str_putc( 'b', str ); break;
                case '\t': ret = str_putc( 't', str ); break;
                case '\n': ret = str_putc( 'n', str ); break;
                case '\f': ret = str_putc( 'f', str ); break;
                case '\r': ret = str_putc( 'r', str ); break;
                default:
                    if ( str_putc( 'u', str ) == -1 )
                        return NO;

                    if ( put4hex( (unsigned short)uChar, str ) == -1 )
                        return NO;

                    break;
            }

            if ( ret == -1 )
                return NO;
        }
        else if ( uChar < 0x80 )
        {
            // Escape characters '"' and '\'
            if ( uChar == '"' || uChar == '\\' )
                if ( str_putc( '\\', str ) == -1 )
                    return NO;

            if ( str_putc( uChar, str ) == -1 )
                return NO;
        }
        else if ( s_preferUtf8ForWrite || uChar > 0xFFFF )
        {
            if ( putUtf8( uChar, str ) == -1 )
                return NO;
        }
        else
        {
            if ( put4hex( uChar, str ) == -1 )
                return NO;
        }
    }

    if ( ! str_putc( '"', str ) )
        return NO;

    return YES;
}

@end
