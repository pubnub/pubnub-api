//
//  PNMessage+Protected.h
//  pubnub
//
//  This header help to hide protected methods of
//  message data object so user will be unsable to
//  use them directly (only PubNub client allowed to
//  use them)
//
//
//  Created by Sergey Mamontov on 1/7/13.
//
//

#import "PNMessage.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Protected methods

@interface PNMessage (Protected)


#pragma mark - Class methods

/**
 * Return reference on message data object initialized with
 * message and target channel
 */
+ (PNMessage *)messageWithText:(NSString *)message forChannel:(PNChannel *)channel error:(PNError **)error;


#pragma mark - Instance methods

/**
 * Initialize message instance with text and channel
 */
- (id)initWithText:(NSString *)message forChannel:(PNChannel *)channel;

- (void)setReceiveDate:(NSDate *)receiveDate;


@end