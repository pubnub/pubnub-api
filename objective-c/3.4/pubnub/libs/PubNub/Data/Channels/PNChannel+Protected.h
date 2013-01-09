//
//  PNChannel+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/23/12.
//
//

#import "PNChannel.h"


#pragma mark Class forward

@class PNChannelPresence;


#pragma mark Protected interface methods

@interface PNChannel (Protected)


#pragma mark - Properties

// Stores whether channel presence observation is required
@property (nonatomic, assign, getter = shouldObservePresence) BOOL observePresence;


#pragma mark - Class methods

/**
 * Clear all cached channel instances
 */
+ (void)purgeChannelsCache;


#pragma mark - Instance methods

/**
 * Depending on whether channel was configured
 * to receive presence events or not it will
 * return presence observing channel
 */
- (PNChannelPresence *)presenceObserver;

/**
 * Update channel name
 */
- (void)setName:(NSString *)name;

/**
 * Returns reference on channel name which cane be sent
 * in GET HTTP request to the PubNub service
 */
- (NSString *)escapedName;

/**
 * Update channel update time token
 */
- (void)setUpdateTimeToken:(NSString *)updateTimeToken;

/**
 * Will reset channel last update time token to "0"
 */
- (void)resetUpdateTimeToken;

#pragma mark -


@end;
