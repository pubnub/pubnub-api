//
//  PNBaseRequest+Protected.h
//  pubnub
//
//  This header contains private methods and
//  properties description which can be used
//  internally by library.
//
//
//  Created by Sergey Mamontov on 12/14/12.
//
//
#import "PNBaseRequest.h"


@interface PNBaseRequest (Protected)


#pragma mark - Instance methods

#pragma mark - Processing retry

/**
 * Retrieve how many times request can be
 * rescheduled for processing
 */
- (NSUInteger)allowedRetryCount;

- (void)resetRetryCount;
- (void)increaseRetryCount;

/**
 * Check whether request can retry processing
 * one more time or not
 */
- (BOOL)canRetry;

/**
 * Require from request fully prepared HTTP
 * payload which will be sent to the PubNub
 * service
 */
- (NSString *)HTTPPayload;

#pragma mark -


@end
