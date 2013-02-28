//
//  NSString(PNDemoAddition).h
// 
//
//  Created by moonlight on 1/21/13.
//
//

#import "NSString+PNDemoAddition.h"


#pragma mark Public interface methods

@implementation NSString (PNDemoAddition)


#pragma mark - Instance methods

- (BOOL)isEmptyString {

    return [[self stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0;
}

#pragma mark -


@end