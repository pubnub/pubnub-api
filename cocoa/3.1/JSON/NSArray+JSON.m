#include "JSONExtensions.h"
#include <Foundation/NSArray.h>
#include <Foundation/NSString.h>
#include <ctype.h>
#include "ByteStream.h"
#include "streamutils.h"

static const char * prefixAdd = "  ";

@implementation NSArray (JSON)

- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    [self release];
    return [[NSMutableArray alloc] initFromJSONStream: str error: err];
}

- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) prefix
{
    if ( str_putc( '[', str ) == -1 )
        return NO;

    NSString * newprefix = 0;
    const char * pref = 0;
    if ( prefix )
    {
        newprefix = [[NSString alloc] initWithFormat: @"%@%s",
                                      prefix, prefixAdd];
        pref = [newprefix cString];
        str_putc( '\n', str );
    }
    
    unsigned count = [self count];
    unsigned i;
    for ( i = 0; i < count; ++i )
    {
        if ( i )
        {
            if ( str_putc( ',', str ) == -1 )
                goto failure;

            // Put '\n' after every key-value pair
            if ( prefix && str_putc( '\n', str ) == -1 )
                goto failure;
        }
        
        // Put prefix before every element
        if ( pref && str_puts( pref, str ) == -1 )
            goto failure;

        if ([[self objectAtIndex: i] writeToJSONStream: str
                                     prefix: newprefix] == NO)
            goto failure;
    }

    // Put newline and prefix before ']' if not an empty array
    if ( prefix && i )
    {
        if ( str_putc( '\n', str ) == -1 )
            goto failure;
        if ( str_puts( [prefix cString], str ) == -1 )
            goto failure;
    }

    if ( str_putc( ']', str ) == -1 )
        goto failure;

    [newprefix release];
    return YES;

 failure:
    [newprefix release];
    return NO;
}

@end

@implementation NSMutableArray (JSON)

/*
  State machine diagram.

                                       ----------------------
                                      |                      ^
                                      |                      |
                                      v                      |
  [Start]-( [ )->[BeforeO]-(obj)->[AfterO]-( , )->[AfterC]-(obj)
                     ^               |
                     |<--->(space)   |<--->(space)
                     |               |
                     |                -----( ] )->[Success]
                     |
                      -----( ] )->[Success]

*/

- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    enum State { Start, BeforeObj, AfterObj, AfterComma, Success, Fail };
    
    NSString * F_NOOPENBRACKET = @"JSON array: expected '[', got '%c'";
    NSString * F_BADDELIM = @"JSON array: unexpected delimiter '%c'";
    NSString * F_EOF = @"JSON array: unexpected EOF";

    self = [self initWithCapacity: 0];
    
    id obj = 0;

    enum State state = Start;

    // Skip leading blanks
    int ch = peek_nonblank_char( str );

    // Return 0 if the stream ended
    if ( ch == -1 && str_eof( str ) )
    {
        [self release];
        return 0;
    }

    // Do the parsing
    while ( (ch = str_getc(str)) != -1 )
    {
        switch ( state )
        {
            case Start:
                state = ( ch == '[' ) ? BeforeObj : Fail;
                if ( state == Fail && err )
                    *err = [NSString stringWithFormat: F_NOOPENBRACKET, ch];
                break;
            case BeforeObj:
                if ( ch == ']' )
                    state = Success;
                else if ( isspace( ch ) )
                    ;
                else
                {
                    str_ungetc( ch, str );
                    obj = [[NSObject alloc] initFromJSONStream: str
                                            error: err];
                    state = obj ? AfterObj : Fail;
                }
                break;
            case AfterObj:
                if ( ch == ',' )
                {
                    [self addObject: obj];
                    [obj release];
                    obj = 0;
                    state = AfterComma;
                }
                else if ( ch == ']' )
                    state = Success;
                else if ( isspace( ch ) )
                    ;
                else
                {
                    if ( err )
                        *err = [NSString stringWithFormat: F_BADDELIM, ch];
                    state = Fail;
                }
                break;
            case AfterComma:
                str_ungetc( ch, str );
                obj = [[NSObject alloc] initFromJSONStream: str error: err];
                state = obj ? AfterObj : Fail;
                break;

            default:
                break;
        }

        switch (state)
        {
            case Fail:
                str_ungetc( ch, str );
                goto fail;
                break;
            case Success:
                goto success;
                break;
            default:
                break;
        }
    }

    // We should not get here
    if ( err )
        *err = [NSString stringWithFormat: F_EOF];

 fail:
    [self release];
    return 0;

 success:
    if (obj)
    {
        [self addObject: obj];
        [obj release];
    }
    return self;
}

@end
