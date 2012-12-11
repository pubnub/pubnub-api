//
//  PNConnectionDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#pragma mark Class forward

@class PNConnection, PNError;


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

@end