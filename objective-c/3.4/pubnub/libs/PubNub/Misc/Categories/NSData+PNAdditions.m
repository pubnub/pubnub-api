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

#pragma mark -


@end