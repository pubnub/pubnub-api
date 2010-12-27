#include "JSONExtensions.h"
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>
#include <Foundation/NSNull.h>
#include <Foundation/NSEnumerator.h>
#include "ByteStream.h"
#include "streamutils.h"

static const char * prefixAdd = "  ";

@implementation NSDictionary (JSON)
- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    [self release];
    return [[NSMutableDictionary alloc] initFromJSONStream: str error: err];
}

- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) prefix
{
    NSString * newprefix = 0;
    const char * pref = 0;
    if ( prefix )
    {
        newprefix = [[NSString alloc] initWithFormat: @"%@%s",
                                      prefix, prefixAdd];
        pref = [newprefix cString];
    }

    // open brace goes without prefix
    if ( str_putc( '{', str ) == -1 )
        goto failure;

    if ( pref && str_putc( '\n', str ) == -1 )
        goto failure;
        
    NSEnumerator *enumerator = [self keyEnumerator];

    id key;
    id value;

    unsigned i = 0;
    
    while ((key = [enumerator nextObject]))
    {
        if (i++)
        {
            if (str_putc( ',', str ) == -1)
                goto failure;

            // Put '\n' after every key-value pair
            if ( prefix && str_putc( '\n', str ) == -1 )
                goto failure;
        }

        // In JSON key must be a string
        if ([key isKindOfClass: [NSString class]] == NO)
            goto failure;

        // Put prefix before every key
        if ( pref && str_puts( pref, str ) == -1 )
            goto failure;

        if ([key writeToJSONStream: str ] == NO)
            goto failure;

        if (str_putc( ':', str ) == -1)
            goto failure;

        value = [self objectForKey: key];
        id obj = value ? value : (id)[NSNull null];
        if ([obj writeToJSONStream: str prefix: newprefix ] == NO)
            goto failure;
    }

    // Put newline and prefix before '}' if not an empty dictionary
    if ( prefix && i )
    {
        if ( str_putc( '\n', str ) == -1 )
            goto failure;
        if ( str_puts( [prefix cString], str ) == -1 )
            goto failure;
    }
        
    if ( str_putc( '}', str ) == -1 )
        goto failure;

    [newprefix release];
    return YES;

 failure:
    [newprefix release];
    return NO;
}

@end

@implementation NSMutableDictionary (JSON)

/*

  State machine diagram.
                                ------------------------------------------
                               |                                          ^
                               v                                          |
  [Start]-({)->[BKey]-(str)->[AKey]-(:)->[BVal]-(obj)->[AVal]-(,)->[AC]-(str)
                  |            |                         |
                  |            |                         |
                  |<->(space)   <-->(space)              |<-->(space)
                  |                                      |
                   ---(})->[Success]                      ----(})->[Success]

*/

- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    enum State {
        Start, BeforeKey, AfterKey, BeforeVal, AfterVal, AfterComma,
        Success, Fail
    };

    NSString * F_NOOPENBRACE = @"JSON dict: expected '{', got '%c'";
    NSString * F_BADKEYDELIM = @"JSON dict: unexpected key delimiter '%c'";
    NSString * F_BADVALDELIM =
        @"JSON dict: unexpected value delimiter '%c', key=%@";
    NSString * F_EOF = @"JSON dict: unexpected EOF";

    self = [self initWithCapacity: 0];
    
    NSString * key = 0;
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
                state = ( ch == '{' ) ? BeforeKey : Fail;
                if ( state == Fail && err )
                    *err = [NSString stringWithFormat: F_NOOPENBRACE, ch];
                break;
            case BeforeKey:
                if ( ch == '}' )
                    state = Success;
                else if ( isspace( ch ) )
                    ;
                else
                {
                    str_ungetc( ch, str );
                    key = [[NSString alloc] initFromJSONStream: str
                                            error: err];
                    state = key ? AfterKey : Fail;
                }
                break;
            case AfterKey:
                if ( isspace(ch) )
                    ;
                else if ( ch == ':' )
                    state = BeforeVal;
                else
                {
                    if ( err )
                        *err = [NSString stringWithFormat: F_BADKEYDELIM, ch];
                    state = Fail;
                }
                break;
            case BeforeVal:
                str_ungetc( ch, str );

                obj = [[NSObject alloc] initFromJSONStream: str error: err];
                state = obj ? AfterVal : Fail;
                break;
            case AfterVal:
                if ( ch == ',' )
                {
                    [self setObject: obj forKey: key];
                    [obj release];
                    [key release];
                    state = AfterComma;
                }
                else if ( ch == '}' )
                    state = Success;
                else if ( isspace(ch ) )
                    ;
                else
                {
                    if ( err )
                        *err = [NSString stringWithFormat: F_BADVALDELIM, ch, key];
                    state = Fail;
                }
                break;
            case AfterComma:
                str_ungetc( ch, str );

                key = [[NSString alloc] initFromJSONStream: str error: err];
                state = key ? AfterKey : Fail;
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
    if ( key && obj )
    {
        [self setObject: obj forKey: key];
        [obj release];
        [key release];
    }
    
    return self;
}

@end
