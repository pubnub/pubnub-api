//
//  PNTimeTokenRequest.m
//  pubnub
//
//  This request object is used to describe
//  server time token retrival request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNTimeTokenRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNConstants.h"


#pragma mark Public interface methods

@implementation PNTimeTokenRequest


#pragma mark - Instance methods

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/time/%@",
            kPNRequestAPIVersionPrefix,
            PNServiceResponseCallbacks.timeTokenCallback];
}

#pragma mark -


@end
