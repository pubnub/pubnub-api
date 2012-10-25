#ifndef _INCLUDED_streamutils_h
#define _INCLUDED_streamutils_h

@class ByteIStream;

int get_nonblank_char( ByteIStream * str );
int peek_nonblank_char( ByteIStream * str );

#endif /* _INCLUDED_streamutils_h */
