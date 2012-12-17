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

#import "PNLeaveRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PNChannel.h"


@interface PNLeaveRequest ()


#pragma mark - Properties

// Stores comma-separated channel names list
@property (nonatomic, strong) NSString *channelsList;


@end


@implementation PNLeaveRequest


#pragma mark - Class methods

+ (PNLeaveRequest *)leaveRequestForChannel:(PNChannel *)channel {
    
    return [self leaveRequestForChannels:@[channel]];
}

+ (PNLeaveRequest *)leaveRequestForChannels:(NSArray *)channels {
    
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
    }
    
    
    return self;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/presence/sub_key/%@/channel/%@/leave?uuid=%@&callback=%@",
            kPNRequestAPIVersionPrefix,
            [PubNub sharedInstance].configuration.subscriptionKey,
            self.channelsList,
            [PubNub clientIdentifier],
            PNServiceResponseCallbacks.leaveChannelCallback];
}

#pragma mark -


@end
