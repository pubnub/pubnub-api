//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//


#import "NSData+PNAdditions.h"


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

#pragma mark -


@end