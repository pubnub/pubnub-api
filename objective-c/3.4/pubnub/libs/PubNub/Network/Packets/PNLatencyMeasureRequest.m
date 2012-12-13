//
//  PNLatencyMeasureRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import "PNLatencyMeasureRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PubNub.h"


#pragma mark Public interface methods

@implementation PNLatencyMeasureRequest


#pragma mark - Instance methods

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/publish/%@/%@/%@/%@/%@/%@?uuid=%@",
            kPNRequestAPIVersionPrefix,
            [PubNub sharedInstance].configuration.publishKey,
            [PubNub sharedInstance].configuration.subscriptionKey,
            [PubNub sharedInstance].configuration.secretKey,
            [kPNLatencyMeterChannel stringByAppendingFormat:@"-%@",
             [PubNub sharedInstance].launchSessionIdentifier],
            PNServiceResponseCallbacks.latencyMeasureMessage,
            @"1",
            [PubNub clientIdentifier]];
}

@end
