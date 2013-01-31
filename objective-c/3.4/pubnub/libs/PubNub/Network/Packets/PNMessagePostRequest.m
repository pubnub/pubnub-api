//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  message sending request which will be
//  scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/28/12.
//
//

#import "PNMessagePostRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNMessage+Protected.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PNChannel+Protected.h"


#pragma mark Private interface methods

@interface PNMessagePostRequest ()


#pragma mark - Properties

// Stores reference on message object which will
// be processed
@property (nonatomic, strong) PNMessage *message;


#pragma mark - Instance methods

/**
 * Retrieve message post request signature
 */
- (NSString *)signature;


@end


#pragma mark Public interface methods

@implementation PNMessagePostRequest


#pragma mark - Class methods

+ (PNMessagePostRequest *)postMessageRequestWithMessage:(PNMessage *)message; {

    return [[[self class] alloc] initWithMessage:message];
}


#pragma mark - Instance methods

- (id)initWithMessage:(PNMessage *)message {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.message = message;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.sendMessageCallback;
}

- (NSString *)resourcePath {

    // Encode message with % so it will be delivered w/o damages to
    // the PubNub service
    NSString *escapedMessage = [self.message.message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"%@/publish/%@/%@/%@/%@/%@_%@/%@?uuid=%@",
                    kPNRequestAPIVersionPrefix,
                    [PubNub sharedInstance].configuration.publishKey,
                    [PubNub sharedInstance].configuration.subscriptionKey,
                    [self signature],
                    [self.message.channel escapedName],
                    [self callbackMethodName],
                    self.shortIdentifier,
                    escapedMessage,
                    [PubNub escapedClientIdentifier]];
}

- (NSString *)signature {

    NSString *signature = @"0";
    NSString *secretKey = [PubNub sharedInstance].configuration.secretKey;
    if ([secretKey length] > 0) {

        NSString *signedRequestPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",
                        [PubNub sharedInstance].configuration.publishKey,
                        [PubNub sharedInstance].configuration.subscriptionKey,
                        secretKey,
                        [self.message.channel escapedName],
                        self.message.message];

        signature = PNHMACSHA256String(secretKey, signedRequestPath);
    }


    return signature;
}

#pragma mark -


@end