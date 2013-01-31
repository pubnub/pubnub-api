//
//  PNMessageChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between service communication
//  channel and PubNub client
//
//
//  Created by Sergey Mamontov on 12/29/12.
//
//


#pragma mark Class forward

@class PNServiceChannel, PNMessagesHistory, PNResponse;
@class PNHereNow;


@protocol PNServiceChannelDelegate<NSObject>


@required

/**
 * Sent to the delegate when time token arrived
 * from backend by request
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken;

/**
 * Sent to the delegate when some error occurred
 * while tried to process time token retrieve request
 */
- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error;

/**
 * Sent to the delegate when latency meter information
 * arrived from backend
 */
- (void)  serviceChannel:(PNServiceChannel *)channel
didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth;


/**
 * Sent to the delegate right before message post
 * request will be sent to the PubNub service
 */
- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message;

/**
 * Sent to the delegate when PubNub service responded
 * that message has been processed
 */
- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message;

/**
 * Sent to the delegate if PubNub reported with
 * processing error or message was unable to send
 * because of some other issues
 */
- (void)serviceChannel:(PNServiceChannel *)channel
    didFailMessageSend:(PNMessage *)message
             withError:(PNError *)error;

/**
 * Sent to the delegate when PubNub service responded
 * on history download request
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history;

/**
 * Sent to the delegate when PubNub service refused to
 * return history for specified channel
 */
- (void)         serviceChannel:(PNServiceChannel *)serviceChannel
didFailHisoryDownloadForChannel:(PNChannel *)channel
                      withError:(PNError *)error;

/**
 * Sent to the delegate when PubNub service responded on
 * participants list request
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants;

/**
 * Sent to the delegate when PubNub service failed to retrieve
 * participants list for specified channel
 */
- (void)               serviceChannel:(PNServiceChannel *)serviceChannel
didFailParticipantsListLoadForChannel:(PNChannel *)channel
                            withError:(PNError *)error;

@end