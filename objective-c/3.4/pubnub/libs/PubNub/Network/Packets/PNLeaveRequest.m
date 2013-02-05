//
//  PNLeaveRequest.m
//  pubnub
//
//  This request instance is used to describe
//  channel(s) leave request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNLeaveRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"


@interface PNLeaveRequest ()


#pragma mark - Properties

// Stores reference on channels list
@property (nonatomic, strong) NSArray *channels;

// Stores reference on whether connection should
// be closed before sending this message or not
@property (nonatomic, assign, getter = shouldCloseConnection) BOOL closeConnection;

// Stores whether leave request was sent to subscribe
// on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;


@end


@implementation PNLeaveRequest


#pragma mark - Class methods

+ (PNLeaveRequest *)leaveRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isLeavingByUserRequest {
    
    return [self leaveRequestForChannels:@[channel] byUserRequest:isLeavingByUserRequest];
}

+ (PNLeaveRequest *)leaveRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {
    
    return [[[self class] alloc] initForChannels:channels byUserRequest:isLeavingByUserRequest];
}


#pragma mark - Instance methods

- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        self.sendingByUserRequest = isLeavingByUserRequest;
        self.closeConnection = YES;
        self.channels = [NSArray arrayWithArray:channels];
    }
    
    
    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.leaveChannelCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub_key/%@/channel/%@/leave?uuid=%@&callback=%@_%@",
                                      [PubNub sharedInstance].configuration.subscriptionKey,
                                      [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
                                      [PubNub escapedClientIdentifier],
                                      [self callbackMethodName],
                                      self.shortIdentifier];
}

#pragma mark -


@end
