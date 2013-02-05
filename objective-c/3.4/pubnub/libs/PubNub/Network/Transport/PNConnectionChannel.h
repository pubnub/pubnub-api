//
//  PNConnectionChannel.h
//  pubnub
//
//  Connection channel is intermediate class
//  between transport network layer and other
//  library classes.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionChannelDelegate.h"
#import "PNRequestsQueueDelegate.h"
#import "PNConnectionDelegate.h"


#pragma mark Structures


#pragma mark Connection channel types

// This enum represents list of available connection
// channel types
typedef enum _PNConnectionChannelType {
    
    // Channel used to communicate with PubNub messaging
    // service:
    //   - subscription
    //   - presence
    //   - leave
    PNConnectionChannelMessaging,
    
    // Channel used for sending other requests like:
    //   - history
    //   - time token
    //   - latency meter
    //   - list of participants
    PNConnectionChannelService
} PNConnectionChannelType;


// This enum represents list of available connection
// states
typedef enum _PNConnectionChannelState {
    
    // Channel was just created (no connection to
    // PubNub services)
    PNConnectionChannelStateCreated,
    
    // Channel trying to establish connection
    // to PubNub services
    PNConnectionChannelStateConnecting,
    
    // Channel is ready for work (connections
    // established and requests queue is ready)
    PNConnectionChannelStateConnected,
    
    // Channel is disconnecting on user request
    // (for example: leave request for all channels)
    PNConnectionChannelStateDisconnecting,
    
    // Channel is disconnecting on because of error
    PNConnectionChannelStateDisconnectingOnError,
    
    // Channel is ready, but was disconnected and
    // waiting command for connection (or was unable
    // to connect during initialization)
    // All requests queue is alive (if they wasn't
    // flushed by user)
    PNConnectionChannelStateDisconnected
} PNConnectionChannelState;


#pragma mark - Class forward

@class PNBaseRequest;


@interface PNConnectionChannel : NSObject <PNRequestsQueueDelegate, PNConnectionDelegate>


#pragma mark - Properties

// Current connection channel state
@property (nonatomic, assign) PNConnectionChannelState state;

// Connection channel delegate
@property (nonatomic, assign) id<PNConnectionChannelDelegate> delegate;


#pragma mark Class methods

/**
 * Returns reference on fully configured channel which is 
 * ready to be connected and usage
 */
+ (id)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType
                    andDelegate:(id<PNConnectionChannelDelegate>)delegate;


#pragma mark - Instance methods

/**
 * Initialize connection channel which on it's own will
 * initiate socket connection with streams
 */
- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate;

- (void)connect;

/**
 * Check whether connection channel connected and ready
 * for work
 */
- (BOOL)isConnected;

/**
 * Closing connection to the server.
 * Requests queue won't be flushed
 */
- (void)disconnect;


#pragma mark - Requests queue management methods

/**
 * Managing requests queue
 * shouldObserveProcessing - means whether communication channel is
 *                           interested in report that request passed
 *                           in this method was completed or not (
 *                           PubNub service completed request processing)
 */
- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing;

/**
 * Triggering requests queue execution (maybe it was locked
 * with previous request and waited)
 */
- (void)scheduleNextRequest;

/**
 * Ask connection to stop pulling requests from request queue
 * and wait for further commands
 */
- (void)unscheduleNextRequest;

/**
 * Remove particular request which was scheduled with this
 * communication channel to queue
 */
- (void)unscheduleRequest:(PNBaseRequest *)request;

/**
 * Remove all requests which was scheduled with this
 * communication channel
 */
- (void)clearScheduledRequestsQueue;

#pragma mark -


@end
