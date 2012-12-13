//
//  PNConnectionDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#pragma mark Class forward

@class PNConnection, PNError;


#pragma mark - Connection observer delegate methods

@protocol PNConnectionDelegate <NSObject>

@optional

/**
 * Sent to the delegate when both streams (read/write) 
 * connected to the opened socket
 */
- (void)connection:(PNConnection *)connection connectedToHost:(NSString *)hostName;

/**
 * Sent to the delegate when both streams (read/write)
 * disconnected from remote host
 */
- (void)connection:(PNConnection *)connection disconnectedFromHost:(NSString *)hostName;

/**
 * Sent to the delegate when one of the stream (read/write)
 * was unable to open connection with socket
 */
- (void)connection:(PNConnection *)connection failedWithError:(PNError *)error;

/**
 * Sent to the delegate when one of the streams recieved
 * error and connection is forced to close because of it
 */
- (void)connection:(PNConnection *)connection closedWithError:(PNError *)error;

#pragma mark -


@end


#pragma mark - Connection data source delegate methods

@protocol PNConnectionDataSource <NSObject>

@required

/**
 * Check whether data source can provide connection
 * with data which can be sent over the network
 * to PubNub services (requests will be executed
 * automatically)
 */
- (BOOL)hasDataForConnection:(PNConnection *)connection;

- (NSString *)nextRequestIdentifierForConnection:(PNConnection *)connection;

/**
 * Delegate should provide serialized data which is ready
 * to be sent via sockey connection
 */
- (NSData *)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier;

/**
 * Sent when connection started request processing
 * (sending payload via sockets)
 */
- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Notify data source that request with specified identifier
 * has been sent, so it should be removed from queue
 */
- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier;

- (void)connection:(PNConnection *)connection failedToProcessRequestWithIdentifier:(NSString *)requestIdentifier;

@end