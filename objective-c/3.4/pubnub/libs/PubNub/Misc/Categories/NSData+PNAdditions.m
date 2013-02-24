//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//


#import "NSData+PNAdditions.h"

#include <zlib.h>

#pragma mark Public interface methods

@implementation NSData (PNAdditions)


#pragma mark - Instance methods

- (unsigned long long int)unsignedLongLongFromHEXData {

    return strtoull([self bytes], NULL, 16);;
}

- (NSString *)HEXString {

    NSUInteger capacity = [self length];
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [self bytes];

    // Iterate over the bytes
    for (int i=0; i < [self length]*0.5f; ++i) {

      [stringBuffer appendFormat:@"%02X", (NSUInteger)dataBuffer[i]];
    }


    return stringBuffer;
}

- (NSData *)gzipInflate {
    if ([self length] == 0) {
        return self;
    }
    unsigned fullLength = [self length];
    unsigned halfLength = [self length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: fullLength + halfLength];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = [self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15 + 32)) != Z_OK) {
        return nil;
    }
    while (!done) {
        if (strm.total_out >= [decompressed length]) { // Make sure we have enough room and reset the lengths.
            [decompressed increaseLengthBy: halfLength];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        status = inflate (&strm, Z_SYNC_FLUSH); // Inflate another chunk.
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd(&strm) != Z_OK) {
        return nil;
    }
    if (done) { // Set real length.
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else {
        return nil;
    }
}

#pragma mark -


@end