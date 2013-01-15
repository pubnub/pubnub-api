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

@class PNServiceChannel, PNResponse;


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

@end