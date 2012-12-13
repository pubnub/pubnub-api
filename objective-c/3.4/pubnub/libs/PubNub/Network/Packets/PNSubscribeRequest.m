//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  channel(s) subscription request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNSubscribeRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PNChannel.h"
#import "PubNub.h"


#pragma mark Private interface methods

@interface PNSubscribeRequest ()


#pragma mark - Properties

// Stores comma-separated channel names list
@property (nonatomic, strong) NSString *channelsList;

// Stores recen channels/presence state update
// time (token)
@property (nonatomic, copy) NSString *updateTimeToken;


@end


#pragma mark Public interface methofs

@implementation PNSubscribeRequest


#pragma mark - Class methods

+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel {
    
    return [self subscribeRequestForChannels:@[channel]];
}

+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels {
    
    return [[[self class] alloc] initForChannels:channels];
}

#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel {
    
    return [self initForChannels:@[channel]];
}

- (id)initForChannels:(NSArray *)channels {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.channelsList = [[channels valueForKey:@"name"] componentsJoinedByString:@","];
        
        
        // Retrieve largest update time token from set of
        // channels (sorting to make larger token to be at
        // the end of the list
        NSSortDescriptor *tokenSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTimeToken" ascending:YES];
        NSArray *timeTokens = [[channels sortedArrayUsingDescriptors:@[tokenSortDescriptor]] valueForKey:@"updateTimeToken"];
        self.updateTimeToken = [timeTokens lastObject];
    }
    
    
    return self;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/subscribe/%@/%@/%@/%@?uuid=%@",
            kPNRequestAPIVersionPrefix,
            [PubNub sharedInstance].configuration.publishKey,
            self.channelsList,
            PNServiceResponseCallbacks.subscriptionCallback,
            self.updateTimeToken,
            [PubNub clientIdentifier]];
}

@end
