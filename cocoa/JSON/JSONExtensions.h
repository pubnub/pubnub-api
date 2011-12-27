#ifndef _INCLUDED_JSONExtensions_h
#define _INCLUDED_JSONExtensions_h

// JSON extensions to Objective C

#include <Foundation/NSObject.h>
#include <Foundation/NSString.h>

@class ByteIStream;
@class ByteOStream;

@interface NSObject (JSON)
- (id) initFromJSONStream: (ByteIStream *) str error: (NSString **) err;
- (BOOL) writeToJSONStream: (ByteOStream *) str prefix: (NSString *) prefix;
- (BOOL) writeToJSONStream: (ByteOStream *) str;
@end

@interface NSString (JSON)
+ (BOOL) preferUtf8ForWritingJSON;
+ (void) setPreferUtf8ForWritingJSON: (BOOL) val;
@end


#endif // _INCLUDED_JSONExtensions_h
