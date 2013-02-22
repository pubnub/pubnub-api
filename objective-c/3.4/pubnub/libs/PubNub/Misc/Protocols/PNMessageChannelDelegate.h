//
//  PNMessageChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between message communication
//  channel and PubNub client
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//


#pragma mark Class forward

@class PNMessagingChannel, PNMessage;
@class PNPresenceEvent;


@protocol PNMessageChannelDelegate <NSObject>

/**
 * Sent to the delegate when client successfully
 * subscribed on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didSubscribeOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client successfully
 * restored subscription on previous set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to subscribe
 * on channels because of error
 */
- (void)  messagingChannel:(PNMessagingChannel *)messagingChannel
didFailSubscribeOnChannels:(NSArray *)channels
                 withError:(PNError *)error;

/**
 * Sent to the delegate when client unsubscribed from
 * specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didUnsubscribeFromChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to unsubscribe
 * from channels because of error
 */
- (void)    messagingChannel:(PNMessagingChannel *)messagingChannel
didFailUnsubscribeOnChannels:(NSArray *)channels
                   withError:(PNError *)error;

/**
 * Sent to delegate when client received message from channel
 * on which it subscribed
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveMessage:(PNMessage *)message;

/**
 * Sent to delegate when client received presence event from channel
 * on which it subscribed
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event;

#pragma mark -


@end