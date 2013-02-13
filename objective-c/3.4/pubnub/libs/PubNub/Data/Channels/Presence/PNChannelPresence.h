//
//  PNChannelPresence.h
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
//  Created by Sergey Mamontov.
//
//

#import <Foundation/Foundation.h>
#import "PNChannel.h"


@interface PNChannelPresence : PNChannel


#pragma mark Class methods

/**
 * Retrieve configured presence observing object 
 * for specified channel
 */
+ (PNChannelPresence *)presenceForChannel:(PNChannel *)channel;

#pragma mark -


@end
