//
//  PNServiceChannel.h
//  pubnub
//
//  This channel is required to manage
//  service message sending to PubNub service.
//  Will send messages like:
//      - publish
//      - time
//      - history
//      - here now (list of participants)
//      - "ping" (latency measurement if enabled)
//
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/15/12.
//
//

#import "PNConnectionChannel.h"
#import "PNConnectionChannelDelegate.h"


@protocol PNServiceChannelDelegate;


@interface PNServiceChannel : PNConnectionChannel


#pragma mark Properties

// Stores reference on service channel delegate which is
// interested in service message event tracking
@property (nonatomic, pn_desired_weak) id<PNServiceChannelDelegate> serviceDelegate;


#pragma mark - Class methods

/**
 * Return reference on configured service communication
 * channel with specified delegate
 */
+ (PNServiceChannel *)serviceChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate;


#pragma mark - Instance methods

#pragma mark - Messages processing methods

/**
 * Generate message sending request to specified channel
 */
- (PNMessage *)sendMessage:(NSString *)message toChannel:(PNChannel *)channel;

/**
 * Sends configured message request to the PubNub service
 */
- (void)sendMessage:(PNMessage *)message;


#pragma mark -


@end
