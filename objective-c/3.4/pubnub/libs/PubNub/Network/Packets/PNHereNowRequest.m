//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import "PNHereNowRequest.h"
#import "PNChannel+Protected.h"
#import "PNRequestsImport.h"
#import "PubNub+Protected.h"


#pragma mark Private interface methods

@interface PNHereNowRequest ()


#pragma mark - Properties

// Stores reference on channel for which participants
// list will be requested
@property (nonatomic, strong) PNChannel *channel;


@end


@implementation PNHereNowRequest


#pragma mark Class methods

+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel {

    return [[[self class] alloc] initWithChannel:channel];
}


#pragma mark - Instance methods

- (id)initWithChannel:(PNChannel *)channel {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.channel = channel;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.channelParticipantsCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@?callback=%@_%@",
                                      [PubNub sharedInstance].configuration.subscriptionKey,
                                      [self.channel escapedName],
                                      [self callbackMethodName],
                                      self.shortIdentifier];
}



#pragma mark -


@end