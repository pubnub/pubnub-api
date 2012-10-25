#ifndef _INCLUDED_jsunicode_h
#define _INCLUDED_jsunicode_h

@class ByteIStream;
@class ByteOStream;

// Reads 4 bytes representing hex numbers from bytestream and converts
// them to short integer. Returns that integer or -1 on error.
int get4hex( ByteIStream * str );

// Converts uChar into 4 hex characters (0-9a-f) and writes them to bytestream.
// Returns 0 on success and -1 on error.
int put4hex( unsigned short uChar, ByteOStream * str );

// Writes UTF8 representation of uChar into bytestream.
// Returns 0 on success and -1 on error.
int putUtf8( int uChar, ByteOStream * str );

// Converts uChar into UTF8 representation and puts the bytes into buffer.
// Returns the number of added bytes.
int intToUtf8( int uChar, unsigned char * buffer );

// Returns the number of bytes in UTF8 representation of uChar.
int utf8length( int uChar );

#endif // _INCLUDED_jsunicode_h
