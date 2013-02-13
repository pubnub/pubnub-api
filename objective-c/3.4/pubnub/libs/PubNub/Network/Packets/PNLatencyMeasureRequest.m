//
//  PNLatencyMeasureRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import "PNLatencyMeasureRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PNMessage+Protected.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PNResponse.h"
#import "PNMessage.h"


#pragma mark Private interface methods

@interface PNLatencyMeasureRequest ()


#pragma mark - Properties

// Stores reference on request processing start time
@property (nonatomic, assign) CFAbsoluteTime startTime;

// Stores reference on request processing end time
@property (nonatomic, assign) CFAbsoluteTime endTime;

@end


#pragma mark Public interface methods

@implementation PNLatencyMeasureRequest


#pragma mark - Instance methods

- (id)init {

    // Retrieve reference on channel which is used to measure
    // network latency
    NSString *latencyMeterChannelName = [kPNLatencyMeterChannel stringByAppendingFormat:@"-%@",
                                         [PubNub sharedInstance].launchSessionIdentifier];
    PNChannel *latencyMeterChannel = [PNChannel channelWithName:latencyMeterChannelName];
    PNMessage *message = [PNMessage messageWithText:@"1" forChannel:latencyMeterChannel error:NULL];

    // Use super class initialization method to prepare latency meter request
    self = [super initWithMessage:message];


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.latencyMeasureMessageCallback;
}

- (void)increaseRetryCount {

    // Forward to the super class
    [super increaseRetryCount];


    // Reset start/stop time
    self.startTime = 0.0;
    self.endTime = 0.0f;
}

- (void)markStartTime {

    self.startTime = CFAbsoluteTimeGetCurrent();
}

- (void)markEndTime {

    self.endTime = CFAbsoluteTimeGetCurrent();
}

- (double)latency {

    return (self.endTime - self.startTime);
}

- (double)bandwidthToLoadResponse:(PNResponse *)response {

    // Retrieve how many data has been received in tracked amount of time
    NSUInteger responseLength = [[response content] length];


    return responseLength / [self latency];
}

#pragma mark -


@end
