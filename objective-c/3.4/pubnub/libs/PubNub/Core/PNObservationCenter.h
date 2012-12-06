//
//  PNObservationCenter.h
//  pubnub
//
//  Observation center will allow to subscribe
//  for particular events with handle block
//  (block will be provided by subscriber)
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import <Foundation/Foundation.h>
#import "PNStructures.h"


@interface PNObservationCenter : NSObject


#pragma mark Class methods

/**
 * Returns reference on shared observer center instance
 * which manage all observers and notify them by request
 * or notification.
 */
+ (void)defaultCenter;


#pragma mark - Instance methods

/**
 * Add/remove observers which would like to know when PubNub client 
 * is connected/disconnected to/from PubNub services at specified
 * origin.
 */
- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;
- (void)removeClientConnectionStateObserver:(id)observer;


#pragma mark -

@end
