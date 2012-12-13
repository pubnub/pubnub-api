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

#import "PNBaseRequest.h"


@interface PNLatencyMeasureRequest : PNBaseRequest

@end
