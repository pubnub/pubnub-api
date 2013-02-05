//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  message sending request which will be
//  scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/28/12.
//
//

#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNMessage;


@interface PNMessagePostRequest : PNBaseRequest


#pragma mark - Class methods

/**
 * Return reference on fully configured request instance
 * which will allow to send specified message to specified
 * channel
 */
+ (PNMessagePostRequest *)postMessageRequestWithMessage:(PNMessage *)message;


#pragma mark - Instance methods

/**
 * Initialize instance with specified message and
 * list of channels to which this message should
 * be sent
 */
- (id)initWithMessage:(PNMessage *)message;

#pragma mark -


@end