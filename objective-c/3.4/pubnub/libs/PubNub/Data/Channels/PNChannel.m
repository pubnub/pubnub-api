//
//  PNChannel.m
//  pubnub
//
//  Represents object which is used to subscribe
//  for channels and presence.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNChannel.h"


#pragma mark Public interface methods

@implementation PNChannel


#pragma mark - Instance methods

/**
 * Realoded init method to perform some
 * intial configuration
 */
- (id)init {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        [self resetUpdateTimeToken];
    }
    
    
    return self;
}

- (void)resetUpdateTimeToken {
    
    self.updateTimeToken = @"0";
}

#pragma mark -


@end
