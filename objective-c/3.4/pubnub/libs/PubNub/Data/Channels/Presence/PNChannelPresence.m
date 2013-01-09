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

#import "PNChannelPresence+Protected.h"


#pragma mark Public interface methods

@implementation PNChannelPresence


#pragma mark - Class methods

/**
 * Retrieve configured presence observing object
 * for specified channel
 */
+ (PNChannelPresence *)presenceForChannel:(PNChannel *)channel {

    return [super channelWithName:[channel.name stringByAppendingString:kPNPresenceObserverChannelSuffix]
            shouldObservePresence:NO];
}

#pragma mark -


@end
