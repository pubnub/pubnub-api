//
//  PNReachability.h
//  pubnub
//
//  This class helps PubNub client to monitor
//  PubNub services reachability.
//  WARNING: It is designed only for internal
//           PubNub client library usage.
//
//
//  Created by Sergey Mamontov on 12/7/12.
//
//

#import <Foundation/Foundation.h>


@interface PNReachability : NSObject


#pragma mark Properties

// Stores reference on block which will be
// called each time when service reachability
// is changed
@property (nonatomic, copy) void(^reachabilityChangeHandleBlock)(BOOL connected);


#pragma mark - Class methods

/**
 * Retrieve reference on reachability monitor
 * instance which will be configured to track
 * PubNub services reachability (using origin
 * provided during PubNub client configuration)
 */
+ (PNReachability *)serviceReachability;


#pragma mark - Instance methods

/**
 * Managing reachability monitor activity
 */
- (void)startServiceReachabilityMonitoring;
- (void)stopServiceReachabilityMonitoring;

/**
 * Check whether service reachability check performed or not
 */
- (BOOL)isServiceReachabilityChecked;

/**
 * Check whether PubNub service can be reached
 * now or not
 */
- (BOOL)isServiceAvailable;

#pragma mark -


@end
