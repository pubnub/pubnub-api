//
//  PNMessage.h
//  pubnub
//
//  This class is used to represent single message
//  which is sent to the PubNub service and will be
//  sent to the PubNub client delegate and observers
//  to notify about that message will/did/fail to send.
//  This object also used to represent arrived messages
//  (received on subscribed channels).
//
//
//  Created by Sergey Mamontov on 1/7/13.
//
//


#import <Foundation/Foundation.h>

#pragma mark Class forward

@class PNChannel;


@interface PNMessage : NSObject


#pragma mark - Properties

// Stores reference on channel to which this message
// should be sent
@property (nonatomic, readonly, strong) PNChannel *channel;

// Stores reference on message body
@property (nonatomic, readonly, strong) id message;

// Stores reference on date when this message was received
// (doesn't work for history, only for presence events)
@property (nonatomic, readonly, strong) NSDate *receiveDate;

#pragma mark -


@end