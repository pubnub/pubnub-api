//
//  PNDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between user code and PubNub
//  client instance.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//


#pragma mark Class forward

@class PubNub, PNError;


@protocol PNDelegate <NSObject>

@optional

/**
 * Called on delegate when some client runtime error occurred
 * (mostly because of configuration/connection when connected)
 */
- (void)pubnubClient:(PubNub *)client error:(PNError *)error;

/**
 * Called on delegate when client is about to initiate connection
 * to the origin
 */
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin;

/**
 * Called on delegate when client successfully connected to the
 * origin and perfomed initial calls (time token requests to make
 * connection keep-alive)
 */
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin;

/**
 * Called on delegate when client disconnected from PubNub services
 * and ready for new session
 */
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin;

/**
 * Called on delegate when come error occurred during PubNub client
 * connection session and it will be closed
 */
- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error;

/**
 * Called on delegate when come error occurred during PubNub client
 * connection session and it was closed
 */
- (void)pubnubClient:(PubNub *)client didDisconnectWithError:(PNError *)error;

/**
 * Called on delegate when occurred error while tried to connect
 * to PubNub services
 * error - returned error will contain information about origin
 *         host name and error code which caused this error
 */
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error;

/**
 * Called on delegate when some kind of error occurred during 
 * subscription creation
 * error - returned error will contain information about channel
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;


#pragma mark - Configuration override delegate methods

/**
 * This method allow to override value passed in configuration
 * during client initalization.
 * This method called when service reachabilty reported that 
 * service are available and previous session is failed because
 * of network error or even not launched.
 * We can change client configuration, but it will trigger 
 * client hard reset (if connected)
 */
- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;

@end
