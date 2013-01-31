//
//  PNMessagingChannel.h
//  pubnub
//
//  This channel instance is required for
//  messages exchange between client and
//  PubNub service:
//      - channels messages (subscribe)
//      - channels presence events
//      - leave
//
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNConnectionChannel.h"
#import "PNMessageChannelDelegate.h"


#pragma mark Class forward

@class PNChannel;


@interface PNMessagingChannel : PNConnectionChannel


#pragma mark - Properties

// Stores reference on delegate which is interested in
// messaging channel events
@property (nonatomic, pn_desired_weak) id<PNMessageChannelDelegate> messagingDelegate;


#pragma mark - Class methods

/**
 * Return reference on configured messages communication
 * channel with specified delegate
 */
+ (PNMessagingChannel *)messageChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate;


#pragma mark - Instance methods

#pragma mark - Connection management

/**
 * This method allow to disconnect communication channel from
 * remote PubNub services and perform channel reset if required
 */
- (void)disconnectWithReset:(BOOL)shouldResetCommunicationChannel;


#pragma mark - Channels management

- (NSArray *)subscribedChannels;

- (BOOL)isSubscribedForChannel:(PNChannel *)channel;

/**
 * Will re-subscribe client to all channels on
 * which it was subscribed before.
 * Each channel will receive leave event notification
 */
- (void)resubscribe;

/**
 * Will restore channels subscription if doesn't
 * set that it should resubscribe
 */
- (void)restoreSubscription:(BOOL)shouldResubscribe;

/**
 * Will resubscribe on channels to receive messages from
 * PubNub services (received time token which can be used
 * to wait in long poll mode)
 */
- (void)updateSubscription;

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
- (void)subscribeOnChannels:(NSArray *)channels;

/**
 * Same function as -subscribeOnChannels: but also allow
 * to specify whether 'leave' presence event should be
 * generated or not
 */
- (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;

/**
 * Will unsubscribe from all channels with which it
 * communicate now.
 * This method also will trigger 'leave' presence event
 * if withPresenceEvent flag is set to 'YES'
 *
 * @return Returns list of channels from which client
 *         will unsubscribe
 */
- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent;

/**
 * Will unsubscribe client from set of channels.
 * Specified set of channels will be removed from 
 * the list of subscribed channels.
 * Leave event will be sent on provided list of 
 * channels.
 */
- (void)unsubscribeFromChannels:(NSArray *)channels;

/**
 * Same function as -unsubscribeFromChannels: but also allow
 * to specify whether 'leave' presence event should be
 * generated or not
 */
- (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;


#pragma mark - Presence observation management

- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;
- (void)enablePresenceObservationForChannels:(NSArray *)channels;
- (void)disablePresenceObservationForChannels:(NSArray *)channels;

#pragma mark -


@end
