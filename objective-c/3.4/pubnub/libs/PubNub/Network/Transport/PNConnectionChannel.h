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
#import "PNConnectionChannel+Protected.h"
#import "PNConnectionChannelDelegate.h"
#import "PNConnectionDelegate.h"


#pragma mark Class forward

@class PNBaseRequest;


@interface PNConnectionChannel : NSObject <PNConnectionDelegate>


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
+ (PNConnectionChannel *)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType;


#pragma mark - Instance methods

/**
 * Initialize connection channel which on it's own will
 * initiate socket connection with streams
 */
- (id)initWithType:(PNConnectionChannelType)connectionChannelType;

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
 */
- (void)scheduleRequest:(PNBaseRequest *)request;
- (void)unscheduleRequest:(PNBaseRequest *)request;
- (void)clearScheduledRequestsQueue;

#pragma mark -


@end
