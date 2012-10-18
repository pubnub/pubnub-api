#include "JSONExtensions.h"
#include <Foundation/NSValue.h>
#include <Foundation/NSString.h>
#include <ctype.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include "ByteStream.h"
#include "streamutils.h"

@implementation NSNumber (JSON)

/*
  I implement the parsing of JSON number to make an exersize in state machine
  coding. It would be much simpler to read the token into a buffer and call
  strtod() after that.
  
  State machine diagram for JSON number parsing.

  I allow 2 extensions over http://json.org:
  1. '+' is allowed in front of the number,
  2. Unsigned hexadecimal numbers are allowed in the form 0<x|X><hex-digit>.

 -> (0)-->[UnsignedZero]

 -> (1-9)---------------------
                              |
                              v
 -> (+-)-->[Sign]-(1-9)->[SignedNum]-(.)->[Frac]-(0-9)->[InFrac]-(eE)-->[Exp]
             |                |                            |
              ----(0)->[S0]   |<---->(0-9)                 |<->(0-9)
                              |                            |
                              |------(eE)->[Exp]            -(delim)->[Success]
                              |
                               ------(delim)->[Success]


           [Exp]-(+-)->[SignedExp]-(0-9)->[InExp]-(delim)->[Success]
             |                               |
              ---(0-9)->[InExp]               <-->(0-9)



           [S0]-(.)->[Frac]
            |
            |---(eE)->[Exp]
            |
             ---(delim)->[Success]


           [UnsignedZero]-(xX)->[Hex]-(hex-digit)->[InHex]-(delim)->[Success]
                  |                                   |
                  |-------(.)->[Frac]                  <-->(hex-digit)
                  |
                  |-------(eE)->[Exp]
                  |
                   -------(delim)->[Success]

*/

- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err
{
    enum State {
        Start, Sign, UnsignedZero, SignedZero, SignedNum, Frac, InFrac, Exp,
        SignedExp, InExp, Hex, InHex, Success, Fail
    };

    char buffer[64];
    int capa = sizeof(buffer)-1;
    int i = 0;

    BOOL fraction = NO; // number has '.'
    BOOL exponent = NO; // number has 'e'

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
    while ( (ch = str_getc(str)) != -1 && i < capa )
    {
        switch (state)
        {
            case Start:
                switch (ch)
                {
                    case '+': case '-': state = Sign; break;
                    case '0':           state = UnsignedZero; break;
                    case '1' ... '9':   state = SignedNum; break;
                    default:            state = Fail; break;
                }
                break;
            case Sign:
                switch (ch)
                {
                    case '0':           state = SignedZero; break;
                    case '1' ... '9':   state = SignedNum; break;
                    default:            state = Fail; break;
                }
                break;
            case SignedZero:
                switch (ch)
                {
                    case '.':           state = Frac; break;
                    case 'e': case 'E': state = Exp; break;
                    default:            state = Success; break;
                }
                break;
            case UnsignedZero:
                switch (ch)
                {
                    case '.':           state = Frac; break;
                    case 'e': case 'E': state = Exp; break;
                    case 'x': case 'X': state = Hex; break;
                    default:            state = Success; break;
                }
                break;
            case SignedNum:
                switch (ch)
                {
                    case '0' ... '9':   state = SignedNum; break;
                    case '.':           state = Frac; break;
                    case 'e': case 'E': state = Exp; break;
                    default:            state = Success; break;
                }
                break;
            case Frac:
                fraction = YES;
                switch (ch)
                {
                    case '0' ... '9':   state = InFrac; break;
                    default:            state = Fail; break;
                }
                break;
            case InFrac:
                switch (ch)
                {
                    case '0' ... '9':   state = InFrac; break;
                    case 'e': case 'E': state = Exp; break;
                    default:            state = Success; break;
                }
                break;
            case Exp:
                exponent = YES;
                switch (ch)
                {
                    case '+': case '-': state = SignedExp; break;
                    case '0' ... '9':   state = InExp; break;
                    default:            state = Fail; break;
                }
                break;
            case SignedExp:
                switch (ch)
                {
                    case '0' ... '9':   state = InExp; break;
                    default:            state = Fail; break;
                }
                break;
            case InExp:
                switch (ch)
                {
                    case '0' ... '9':   state = InExp; break;
                    default:            state = Success; break;
                }
                break;
            case Hex:
                switch (ch)
                {
                    case '0' ... '9':
                    case 'a' ... 'f':
                    case 'A' ... 'F':   state = InHex; break;
                    default:            state = Fail; break;
                }
                break;
            case InHex:
                switch (ch)
                {
                    case '0' ... '9':
                    case 'a' ... 'f':
                    case 'A' ... 'F':   state = InHex; break;
                    default:            state = Success; break;
                }
                break;
            case Success: // fall through
                break;
            case Fail:
                break;
        }

        if (state == Success || state == Fail)
        {
            str_ungetc( ch, str );  // TODO: process error in ungetc()
            goto endparse;
        }
        
        // add valid character to buffer
        buffer[i++] = ch;
    }

 endparse:
    if ( state != Success )
    {
        if ( err )
        {
            if ( state == Fail )
                *err = [NSString stringWithFormat:
                                     @"number: unexpected character '%c'", ch];
            else if ( ch == -1 )
                *err = [NSString stringWithFormat: @"number: unexpected EOF"];
            else if ( i == capa )
                *err = [NSString stringWithFormat:
                                 @"number: can only hold %d characters", capa];
            else
                *err = [NSString stringWithFormat: @"number: internal error"];
        }
        goto failure;
    }

    // Convert buffer to a number and create NSNumber

    buffer[i] = 0;

    char * endp = 0;
    errno = 0;
    double dresult;
    long long lresult;
    if ( fraction || exponent )
        dresult = strtod( buffer, &endp );
    else
        lresult = strtoll( buffer, &endp, 0 );

    if ( errno == ERANGE )
    {
        if ( err )
            *err = [NSString stringWithFormat:
                                 @"number \"%s\" is out of range", buffer];
        goto failure;
    }
    else if ( *endp != '\0' )
    {
        if ( err )
            *err = [NSString stringWithFormat:
                                 @"number \"%s\" is inconsistent with libc",
                             buffer];
        goto failure;
    }

    // Select the proper type among integer ones to save memory.
    
    if (fraction || exponent)
        return [self initWithDouble: dresult];
    else if ( SHRT_MIN <= lresult && lresult <= SHRT_MAX )
        return [self initWithShort: lresult];
    else if ( INT_MIN <= lresult && lresult <= INT_MAX )
        return [self initWithInt: lresult];
    else if ( LONG_MIN <= lresult && lresult <= LONG_MAX )
        return [self initWithLong: lresult];
    else        
        return [self initWithLongLong: lresult];

 failure:
    [self release];
    return 0;
}

- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) unused
{
    const char * p;

    // BOOL is typdef'ed to unsigned char. This code will work only
    // if there is no unsigned chars among JSON scalar types.
    if ( ! strcmp( [self objCType], @encode(BOOL) ) )
        p = [self boolValue] ? "true" : "false";
    else
        p = [[self description] cString];

    int ret = str_puts( p, str );
    return (ret == -1) ? NO : YES;
}

@end
