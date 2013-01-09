//
//  PNConnectionChannel+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNConnectionChannel.h"


@class PNBaseRequest;


@interface PNConnectionChannel (Protected)


#pragma mark - Instance methods

/**
 * Returns whether communication channel is waiting for
 * request processing completion from backebd or not
 */
- (BOOL)isWaitingRequestCompletion:(NSString *)requestIdentifier;

/**
 * Clean up requests stack
 */
- (void)purgeObservedRequestsPool;

/**
 * Retrieve reference on request which was observed by communication
 * channel by it's identifier
 */
- (PNBaseRequest *)observedRequestWithIdentifier:(NSString *)identifier;

- (void)removeObservationFromRequest:(PNBaseRequest *)request;

/**
 * Completely destroys request by removing it from queue and
 * requests observation list
 */
- (void)destroyRequest:(PNBaseRequest *)request;

/**
 * Reconnect main communication channel on which this
 * communication channel is working
 */
- (void)reconnect;

/**
 * Clear communication channel request pool
 */
- (void)clearScheduledRequestsQueue;

#pragma mark -


@end