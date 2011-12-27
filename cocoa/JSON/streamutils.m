#include "streamutils.h"
#include <ctype.h>      // isspace()
#include "ByteStream.h"

int get_nonblank_char( ByteIStream * str )
{
    int c;
    while ( (c = str_getc( str )) != -1 && isspace(c) )
        ;
    return c;
}

int peek_nonblank_char( ByteIStream * str )
{
    /*
    int c;
    while ( (c = str_peekc( str )) != -1 && isspace(c) )
        str_getc( str );  // eat this character
    return c;
    */

    int c = get_nonblank_char( str );
    return (c == -1) ? c : str_ungetc( c, str );
}
