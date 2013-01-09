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


@protocol PNMessageChannelDelegate <NSObject>

/**
 * Sent to the delegate when client successfully
 * subscribed on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)channel didSubscribeOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to subscribe
 * on channels because of error
 */
- (void)  messagingChannel:(PNMessagingChannel *)channel
didFailSubscribeOnChannels:(NSArray *)channels
                 withError:(PNError *)error;

/**
 * Sent to the delegate when client unsubscribed from
 * specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)channel didUnsibscribeFromChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to unsubscribe
 * from channels because of error
 */
- (void)    messagingChannel:(PNMessagingChannel *)channel
didFailUnsubscribeOnChannels:(NSArray *)channels
                   withError:(PNError *)error;


/**
 * Sent to the delegate right before message post
 * request will be sent to the PubNub service
 */
- (void)messagingChannel:(PNMessagingChannel *)channel willSendMessage:(PNMessage *)message;

/**
 * Sent to the delegate when PubNub service responded
 * that message has been processed
 */
- (void)messagingChannel:(PNMessagingChannel *)channel didSendMessage:(PNMessage *)message;

/**
 * Sent to the delegate if PubNub reported with
 * processing error or message was unable to send
 * because of some other issues
 */
- (void)messagingChannel:(PNMessagingChannel *)channel
      didFailMessageSend:(PNMessage *)message
               withError:(PNError *)error;

@end