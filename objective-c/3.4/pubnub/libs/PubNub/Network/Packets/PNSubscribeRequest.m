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

#import "PNSubscribeRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"


#pragma mark Private interface methods

@interface PNSubscribeRequest ()


#pragma mark - Properties

// Stores reference on list of channels on which client
// should subscribe
@property (nonatomic, strong) NSArray *channels;

// Stores recen channels/presence state update
// time (token)
@property (nonatomic, copy) NSString *updateTimeToken;

// Stores whether leave request was sent to subscribe
// on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;


@end


#pragma mark Public interface methofs

@implementation PNSubscribeRequest


#pragma mark - Class methods

+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    return [self subscribeRequestForChannels:@[channel] byUserRequest:isSubscribingByUserRequest];
}

+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    return [[[self class] alloc] initForChannels:channels byUserRequest:isSubscribingByUserRequest];
}

#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    return [self initForChannels:@[channel] byUserRequest:isSubscribingByUserRequest];
}

- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        self.sendingByUserRequest = isSubscribingByUserRequest;
        self.channels = [NSArray arrayWithArray:channels];
        
        
        // Retrieve largest update time token from set of
        // channels (sorting to make larger token to be at
        // the end of the list
        NSSortDescriptor *tokenSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTimeToken" ascending:YES];
        NSArray *timeTokens = [[channels sortedArrayUsingDescriptors:@[tokenSortDescriptor]] valueForKey:@"updateTimeToken"];
        self.updateTimeToken = [timeTokens lastObject];
    }
    
    
    return self;
}

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.subscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.subscriptionCallback;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/subscribe/%@/%@/%@_%@/%@?uuid=%@",
            kPNRequestAPIVersionPrefix,
            [PubNub sharedInstance].configuration.subscriptionKey,
            [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
            [self callbackMethodName],
            self.shortIdentifier,
            self.updateTimeToken,
            [PubNub escapedClientIdentifier]];
}

@end
