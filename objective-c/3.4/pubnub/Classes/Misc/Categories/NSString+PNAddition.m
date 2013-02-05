//
//  NSString(PNAddition).h
// 
//
//  Created by moonlight on 1/21/13.
//
//

#import "NSString+PNAddition.h"


#pragma mark Public interface methods

@implementation NSString (PNAddition)


#pragma mark - Instance methods

- (BOOL)isEmptyString {

    return [[self stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0;
}

#pragma mark -


@end