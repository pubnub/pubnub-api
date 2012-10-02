#include "JSONExtensions.h"
#include <Foundation/NSObject.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSString.h>
#include <Foundation/NSNull.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <ctype.h>                  // isdigit()
#include "ByteStream.h"
#include "streamutils.h"

@implementation NSObject (JSON)
- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    id result = 0;

    // Skip leading blanks
    int c = peek_nonblank_char( str );

    // Return 0 if the stream ended
    if ( c == -1 && str_eof( str ) )
    {
        [self release];
        return 0;
    }

    switch (c)
    {
        case '{':
            result = [[NSMutableDictionary alloc] initFromJSONStream: str error: err];
            break;
        case '[':
            result = [[NSMutableArray alloc] initFromJSONStream: str error: err];
            break;
        case '"':
            result = [[NSString alloc] initFromJSONStream: str error: err];
            break;
        case 't': // fall through
        case 'f':
        case 'n':
        {
            char buffer[8];
            memset( buffer, 0, sizeof(buffer) );

            str_getbytes( str, buffer, (c=='f') ? 5 : 4 );
            if ( strcmp( buffer, "true" ) == 0 )
                result = [[NSNumber alloc] initWithBool: YES];
            else if ( strcmp( buffer, "false" ) == 0 )
                result = [[NSNumber alloc] initWithBool: NO];
            else if ( strcmp( buffer, "null" ) == 0 )
                result = [[NSNull alloc] init]; // [NSNull null];
            else if ( err )
                *err = [NSString stringWithFormat:
                                     @"unrecognized word %s", buffer];
        }
        break;
        default:
        {
            if ( isdigit(c) || c == '+' || c == '-' )
                result = [[NSNumber alloc] initFromJSONStream: str error: err];
            else if ( err )
                *err = [NSString stringWithFormat:
                                     @"unexpected first character '%c'", c];
        }
        break;
    }

    [self release];
    return result;
}

- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) prefix
{
    // If the method is not overriden, this object
    // cannot be represented in JSON

    if ( [self isKindOfClass: [NSDictionary class]] == NO )
    {
        // We should always get here since the method -writeToJSONStream
        // should be implemented for NSDictionary.
        // The "if" is an extra protection against infinite recursion.
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject: [self className] forKey: @"class"];
        [dict setObject: @"unknown JSON representation" forKey: @"error"];
        return [dict writeToJSONStream: str prefix: prefix];
    }

    return NO; // should never get here
}

- (BOOL) writeToJSONStream: (ByteOStream *) str
{
    return [self writeToJSONStream: str prefix: 0];
}

@end

@implementation NSNull (JSON)

- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) unused
{
    int ret = str_puts( "null", str );
    return (ret == -1) ? NO : YES;
}

@end
