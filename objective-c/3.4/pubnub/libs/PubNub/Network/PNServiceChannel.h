//
//  PNServiceChannel.h
//  pubnub
//
//  This channel is required to manage
//  service message sending to PubNub service.
//  Will send messages like:
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


#pragma mark -


@end
