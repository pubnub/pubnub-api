//
//  PNRequestsQueue.h
//  pubnub
//
//  This class was created for iOS PubNub
//  client support to handle request sending
//  via single socket connection.
//  This is singleton class which will help
//  to organize requests into single FIFO
//  pipe.
//
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import <Foundation/Foundation.h>
#import "PNRequestsQueueDelegate.h"
#import "PNConnectionDelegate.h"


#pragma mark Class forward

@class PNBaseRequest;


@interface PNRequestsQueue : NSObject <PNConnectionDataSource>


#pragma mark Class methods

//#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 * Retrieve reference on single queue manager instance
 */
//+ (PNRequestsQueue *)sharedInstance;
//#endif


#pragma mark - Instance methods

/**
 * Managing connection delegates pool
 */
- (void)assignDelegate:(id<PNRequestsQueueDelegate>)delegate;
- (void)resignDelegate:(id<PNRequestsQueueDelegate>)delegate;

/**
 * Will add request into the queue if it is still not
 * there.
 * Returns whether request has been placed into queue 
 * or not
 */
- (BOOL)enqueueRequest:(PNBaseRequest *)request sender:(id)sender;
- (void)removeRequest:(PNBaseRequest *)request;

/**
 * Removes all requests which is not placed for processing
 * into connection buffer
 */
- (void)removeAllRequestsFromSender:(id)sender;

#pragma mark -


@end
