//
//  PNChannelPresence+Protected.h
//  pubnub
//
//  This header helps to hide part of presencd
//  channel implementation from public access
//
//  Created by Sergey Mamontov on 12/25/12.
//
//

#import "PNChannelPresence.h"


#pragma mark Static

// Stores reference on suffix which is used
// to mark channel as presence observer for
// another channel
static NSString * const kPNPresenceObserverChannelSuffix = @"-pnpres";


@interface PNChannelPresence (Protected)


#pragma mark - Class methods

/**
 * Retrieve configured presence observing object
 * for channel with specified name
 */
+ (PNChannelPresence *)presenceForChannelWithName:(NSString *)channelName;

/**
 * Check whether channel name corresponds to presence
 * observing channel or not
 */
+ (BOOL)isPresenceObservingChannelName:(NSString *)channelName;


#pragma mark - Instance methods

/**
 * Retrieve reference on channel for which this presence
 * observing instance was created
 */
- (PNChannel *)observedChannel;

#pragma mark -


@end

