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

#pragma mark - Channels management

/**
 * Will subscribe client for another one channel.
 * This request will add provided channel to the
 * list of channels on which client already subscribed.
 * 
 * Warning: if client connected to the PubNub service
 *          the this method will force client to send
 *          "leave" command to all channels on which
 *          client subscribed and then re-subscribe
 *          with new channels list (this is required
 *          so presence event will trigger on specified
 *          channel)
 */
- (void)subscribeForChannel:(PNChannel *)channel;

/**
 * Will unsubscribe client from specified channel.
 * Specified channel will be removed from the list
 * of subscribed channels.
 */
- (void)unsubscribeFromChannel:(PNChannel *)channel;

/**
 * Will subscribe client for set of channels.
 * This request will add provided channels set to the
 * list of channels on which client already subscribed.
 *
 * Warning: if client connected to the PubNub service 
 *          the this method will force client to send
 *          "leave" command to all channels on which 
 *          client subscribed and then re-subscribe 
 *          with new channels list (this is required 
 *          so presence event will trigger on specified
 *          channels)
 */
- (void)subscribeForChannels:(NSArray *)channels;

/**
 * Will unsubscribe client from set of channels.
 * Specified set of channels will be removed from 
 * the list of subscribed channels.
 */
- (void)unsubscribeFromChannels:(NSArray *)channels;


#pragma mark - Prsence observation management

- (void)addPresenceObservationForChannel:(PNChannel *)channel;
- (void)removePresenceObservationForChannel:(PNChannel *)channel;
- (void)addPresenceObservationForChannels:(NSArray *)channels;
- (void)removePresenceObservationForChannelw:(NSArray *)channels;

#pragma mark -


@end
