//
//  PNBaseRequest.m
//  pubnub
//
//  Base request class which will allow to
//  serialize specified data into format
//  which will be sent over socket connection.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNBaseRequest.h"
#import "PubNub+Protected.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"


#pragma mark Private interface methods

@interface PNBaseRequest ()

#pragma mark - Properties

// Stores number of request sending retries
// (when it will reach limit communication
// channel should remove it from queue
@property (nonatomic, assign) NSUInteger retryCount;


@end


#pragma mark - Public interface methods

@implementation PNBaseRequest


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization is successful or not
    if((self = [super init])) {
        
        self.identifier = PNUniqueIdentifier();
        self.shortIdentifier = PNShortenedIdentifierFromUUID(self.identifier);
    }
    
    
    return self;
}

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    return @"0";
}

- (NSString *)resourcePath {
    
    PNLog(PNLogCommunicationChannelLayerWarnLevel, self, @" THIS METHOD SHOULD BE RELOADED IN SUBCLASS");
    
    return @"/";
}

- (PNWriteBuffer *)buffer {
    
    return [PNWriteBuffer writeBufferForRequest:self];
}

- (void)reset {

    self.retryCount = 0;
    self.processing = NO;
    self.processed = NO;
}

- (void)resetRetryCount {

    self.retryCount = 0;
}

- (void)increaseRetryCount {

    self.retryCount++;
}

- (BOOL)canRetry {

    return self.retryCount < [self allowedRetryCount];
}

- (NSUInteger)allowedRetryCount {

    return kPNRequestMaximumRetryCount;
}

- (NSString *)HTTPPayload {

    NSString *acceptEncoding = @"";
    if ([PubNub sharedInstance].configuration.shouldAcceptCompressedResponse) {

        acceptEncoding = @"Accept-Encoding: gzip, deflate\r\n";
    }

    
    return [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\nHost: %@\r\nV: %@\r\nUser-Agent: %@\r\nAccept: */*\r\n%@\r\n",
            [self resourcePath],
            [PubNub sharedInstance].configuration.origin,
            kPNClientVersion,
            kPNClientName,
            acceptEncoding];
}

#pragma mark -


@end
