#include "jsunicode.h"
#include "ByteStream.h"

// Reads 4 bytes representing hex numbers from bytestream and converts
// them to short integer. Returns that integer or -1 on error.

int get4hex( ByteIStream * str )
{
    int j;
    int result = 0;
    int ch;

    for ( j = 3; j >= 0; --j )
    {
        if ( (ch = str_getc( str )) == -1 )
            return -1;
        switch (ch)
        {
            case '0' ... '9':
                result |= (ch - '0') << 4*j;
                break;
            case 'a' ... 'f':
                result |= ((ch - 'a') + 10) << 4*j;
                break;
            case 'A' ... 'F':
                result |= ((ch - 'A') + 10) << 4*j;
                break;
            default:
                return -1;
        }
    }
    return result;
}

// Converts uChar into 4 hex characters (0-9a-f) and writes them to the stream.
// Returns 0 on success and -1 on error.

int put4hex( unsigned short uChar, ByteOStream * str )
{
    int j;
    char hex;

    for ( j = 3; j >= 0; j-- )
    {
        hex = 0x0F & uChar >> (4*j);
        hex = (hex < 10) ? hex + '0' : hex - 10 + 'a';
        if ( str_putc( hex, str ) == -1 )
            return -1;
    }

    return 0;
}

// Writes UTF8 representation of uChar into bytestream.
// Returns 0 on success and -1 on error.

int putUtf8( int uChar, ByteOStream * str )
{
    int ret;
    if ( uChar < 0x80 )
    {
        ret = str_putc( uChar, str );
    }
    else if ( uChar < 0x800 )
    {
        ret = str_putc( 0xC0 | uChar >> 6, str );
        ret = str_putc( 0x80 | (uChar & 0x3F), str );
    }
    else if ( uChar < 0x10000 )
    {
        ret = str_putc( 0xE0 | uChar >> 12, str );
        ret = str_putc( 0x80 | (uChar >> 6 & 0x3F), str );
        ret = str_putc( 0x80 | (uChar & 0x3F), str );
    }
    else if ( uChar < 0x200000 )
    {
        ret = str_putc( 0xF0 | uChar >> 18, str );
        ret = str_putc( 0x80 | (uChar >> 12 & 0x3F), str );
        ret = str_putc( 0x80 | (uChar >> 6 & 0x3F), str );
        ret = str_putc( 0x80 | (uChar & 0x3F), str );
    }
    return (ret == -1) ? -1 : 0;
}

// Converts uChar into UTF8 representation and puts the bytes into buffer.
// Returns the number of added bytes.

int intToUtf8( int uChar, unsigned char * buffer )
{
    if ( uChar < 0x80 )
    {
        buffer[0] = uChar;
        return 1;
    }
    else if ( uChar < 0x800 )
    {
        buffer[0] = 0xC0 | uChar >> 6;
        buffer[1] = 0x80 | (uChar & 0x3F);
        return 2;
    }
    else if ( uChar < 0x10000 )
    {
        buffer[0] = 0xE0 | uChar >> 12;
        buffer[1] = 0x80 | (uChar >> 6 & 0x3F);
        buffer[2] = 0x80 | (uChar & 0x3F);
        return 3;
    }
    else if ( uChar < 0x200000 )
    {
        buffer[0] = 0xF0 | uChar >> 18;
        buffer[1] = 0x80 | (uChar >> 12 & 0x3F);
        buffer[2] = 0x80 | (uChar >> 6 & 0x3F);
        buffer[3] = 0x80 | (uChar & 0x3F);
        return 4;
    }
    return 0;
}

// Returns the number of bytes in UTF8 representation of uChar.

int utf8length( int uChar )
{
    if ( uChar < 0x80 )
        return 1;
    else if ( uChar < 0x800 )
        return 2;
    else if ( uChar < 0x10000 )
        return 3;
    else if ( uChar < 0x200000 )
        return 4;

    return 0;
}
