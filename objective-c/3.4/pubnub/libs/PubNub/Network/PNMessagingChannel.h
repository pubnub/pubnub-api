//
//  PNMessagingChannel.h
//  pubnub
//
//  This channel instance is required for
//  messages exchange between client and
//  PubNub service:
//      - channels messages
//      - channels presence events
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNConnectionChannel.h"


#pragma mark Class forward

@class PNChannel;


@interface PNMessagingChannel : PNConnectionChannel


#pragma mark - Instance methods

#pragma mark - Presence management

/**
 * Send leave event to all channels to which
 * client subscribed at this moment
 */
- (void)leave;


#pragma mark - Channels management

- (void)subscribeForChannel:(PNChannel *)channel;
- (void)unsubscribeFromChannel:(PNChannel *)channel;
- (void)subscribeForChannels:(NSArray *)channels;
- (void)unsubscribeFromChannels:(NSArray *)channels;


#pragma mark - Prsence observation management

- (void)addPresenceObservationForChannel:(PNChannel *)channel;
- (void)removePresenceObservationForChannel:(PNChannel *)channel;
- (void)addPresenceObservationForChannels:(NSArray *)channels;
- (void)removePresenceObservationForChannelw:(NSArray *)channels;

#pragma mark -


@end
