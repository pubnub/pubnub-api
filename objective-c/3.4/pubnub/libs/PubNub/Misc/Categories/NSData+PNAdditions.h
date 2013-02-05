//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//


#import <Foundation/Foundation.h>


@interface NSData (PNAdditions)


#pragma mark Instance methods

/**
 * Allow to extract ull integer from HEX which
 * is represented by string inside NSData
 */
- (unsigned long long int)unsignedLongLongFromHEXData;

/**
 * Allow to extract HEX string from bytes stored
 * inside object
 */
- (NSString *)HEXString;

#pragma mark -


@end