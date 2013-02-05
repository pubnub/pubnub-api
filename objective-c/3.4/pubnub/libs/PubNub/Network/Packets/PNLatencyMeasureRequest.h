//
//  PNLatencyMeasureRequest.h
//  pubnub
//
//  This request object is used to describe
//  message send request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//  This message request will be used by latency
//  profiler to collect information about network
//  latency and provide to the user.
//
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import "PNMessagePostRequest.h"


#pragma mark Class forward

@class PNResponse;


@interface PNLatencyMeasureRequest : PNMessagePostRequest


#pragma mark - Instance methods

/**
 * Latency packet profiling interval manipulation
 */
- (void)markStartTime;
- (void)markEndTime;

/**
 * Calculates request latency
 */
- (double)latency;

/**
 * Calculates network bandwidth based on amount of data
 * sent during request execution time
 * @return bytes per second
 */
- (double)bandwidthToLoadResponse:(PNResponse *)response;

@end
