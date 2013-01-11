//
//  PNConnection.h
//  pubnub
//
//  This is core class for communication over
//  the network with PubNub services.
//  It allow to establish socket connection and
//  organize write packet requests into FIFO queue.
//  
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionDelegate.h"
#import "PNMacro.h"


@interface PNConnection : NSObject


#pragma mark Properties

// Reference on object which will provide
// requests pool for connection
@property (nonatomic, pn_desired_weak) id<PNConnectionDataSource> dataSource;

// Stores reference on connection delegate which also will
// be packet provider for connection
@property (nonatomic, pn_desired_weak) id<PNConnectionDelegate> delegate;


#pragma mark - Class methods

/**
 * Depending on platform will be able to 
 * return few connections when on Mac OS
 * and will reuse same connection on iOS
 */
+ (PNConnection *)connectionWithIdentifier:(NSString *)identifier;

/**
 * Closes all streams and remove connection
 * from connections pool to completly free up
 * resources
 */
+ (void)destroyConnection:(PNConnection *)connection;

/**
 * Close all opened connections which is 
 * stored inside connections pool for reuse
 */
+ (void)closeAllConnections;


#pragma mark - Instance methods

#pragma mark - Requests queue execution management

/**
 * Inform connection to schedule requests queue 
 * processing.
 */
- (void)scheduleNextRequestExecution;

/**
 * Inform connection to stop requests queue 
 * processing (last active request will be sent)
 */
- (void)unscheduleRequestsExecution;


#pragma mark - Connection management

- (BOOL)connect;
- (BOOL)isConnected;
- (BOOL)isDisconnected;

/**
 * Reconnect sockets and streams by user request
 */
- (void)reconnect;

/**
 * Close socket and streams on particular 
 * connection instance
 */
- (void)closeConnection;

#pragma mark -


@end
