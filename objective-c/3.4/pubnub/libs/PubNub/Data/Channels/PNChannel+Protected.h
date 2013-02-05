//
//  PNChannel+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov on 12/23/12.
//
//

#import "PNChannel.h"


#pragma mark Class forward

@class PNChannelPresence;
@class PNPresenceEvent;
@class PNHereNow;


#pragma mark Protected interface methods

@interface PNChannel (Protected)


#pragma mark - Properties

// Stores whether channel presence observation is required
@property (nonatomic, assign, getter = shouldObservePresence) BOOL observePresence;

// Stores number of participants for particular
// channel (this number fetched from presence API
// if it is used and updated when requested list
// of participants)
// INFO: it may differ in count from participants
//       name because of nature of this value
//       update logic
@property (nonatomic, assign) NSUInteger participantsCount;

// Last presence update date
@property (nonatomic, strong) NSDate *presenceUpdateDate;


#pragma mark - Class methods

/**
 * Clear all cached channel instances
 */
+ (void)purgeChannelsCache;


#pragma mark - Instance methods

/**
 * Return whether channel is presence observer or not
 */
- (BOOL)isPresenceObserver;

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
 * Updating cached channel data with information arrived
 * from presence event
 */
- (void)updateWithEvent:(PNPresenceEvent *)event;

/**
 * Updating cached channel data with participants list
 * information
 */
- (void)updateWithParticipantsList:(PNHereNow *)hereNow;

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
