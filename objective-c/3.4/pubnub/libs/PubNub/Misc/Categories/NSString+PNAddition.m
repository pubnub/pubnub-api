//
//  NSString+PNAddition.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/13.
//
//

#import "NSString+PNAddition.h"


#pragma mark Public interface implementation

@implementation NSString (PNAddition)


#pragma mark - Instance methods

- (NSString *)percentEscapedString {
    
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        (CFStringRef)@":/?#[]@!$&’()*+,;=",
                                                                        kCFStringEncodingUTF8);
    
    
    return CFBridgingRelease(escapedString);
}

#pragma mark -

@end
