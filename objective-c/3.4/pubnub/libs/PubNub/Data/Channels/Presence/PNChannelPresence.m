//
//  PNChannelPresence.m
//  pubnub
//
//  Object used to describe presence for
//  specific channel.
//  This is basically channel, but it will
//  apply some rules to his name which will
//  allow him to observer presence on specific
//  channel.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNChannelPresence.h"


#pragma mark Static

// Stores reference on suffix which is used
// to mark channel as presence observer for
// another channel
static NSString * const kPNPresenceObserverChannelSuffix = @"-pnpres";


#pragma mark Public interface methods

@implementation PNChannelPresence


#pragma mark - Class methods

/**
 * Retrieve configured presence observing object
 * for specified channel
 */
+ (PNChannelPresence *)presenceForChannel:(PNChannel *)channel {
    
    return [[[self class] alloc] initForChannel:channel];
}


#pragma mark - Instance methods

/**
 * Initiate presence observing object for specified
 * channel
 */
- (id)initForChannel:(PNChannel *)channel {
    
    // Check whether intialization is successful or not
    if((self = [super init])) {
        
        self.name = [channel.name stringByAppendingString:kPNPresenceObserverChannelSuffix];
    }
    
    
    return self;
}

#pragma mark -


@end
