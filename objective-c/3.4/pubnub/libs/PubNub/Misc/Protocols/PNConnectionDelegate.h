//
//  PNConnectionDelegate.h
//  pubnub
//
//  Describes interface which is used to
//  organize communication between connection
//  (transport layer) and connection channel
//  management code
//
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#pragma mark Class forward

@class PNConnection, PNWriteBuffer, PNResponse, PNError;


#pragma mark - Connection observer delegate methods

@protocol PNConnectionDelegate <NSObject>

@required

/**
 * Sent to the delegate when both streams (read/write) 
 * connected to the opened socket
 */
- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName;

/**
 * Sent to the delegate each time when new response
 * arrives via socket from remote server
 */
- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response;

/**
 * Sent to the delegate when both streams (read/write)
 * disconnected from remote host
 */
- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName;

/**
 * Sent to the delegate when one of the stream (read/write)
 * was unable to open connection with socket
 */
- (void)connection:(PNConnection *)connection connectionDidFailToHost:(NSString *)hostName withError:(PNError *)error;

/**
 * Sent to the delegate when one of the streams recieved
 * error and connection is forced to close because of it
 */
- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error;

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
 * Delegate should provide write buffer which will be used
 * to send serialized data over the network
 */
- (PNWriteBuffer *)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier;

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

/**
 * Notify data source that request with specified identifier
 * has been canceled (unscheduled) from execution
 */
- (void)connection:(PNConnection *)connection didCancelRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Notify data source that request with specified identifier
 * wasn't sent because of some error
 */
- (void)connection:(PNConnection *)connection
        didFailToProcessRequestWithIdentifier:(NSString *)requestIdentifier
         withError:(PNError *)error;

@end