//
//  PNConnectionChannel.m
//  pubnub
//
//  Connection channel is intermediate class
//  between transport network layer and other
//  library classes.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNConnectionChannel.h"
#import "PNConnection+Protected.h"
#import "PNRequestsQueue.h"
#import "PNConnection.h"


#pragma mark Private interface methods

@interface PNConnectionChannel ()


#pragma mark - Properties

// Stores reference on connection which is used
// as transport layer to send messages to the
// PubNub service
@property (nonatomic, strong) PNConnection *connection;

#if __MAC_OS_X_VERSION_MIN_REQUIRED
// Stores reference on array of scheduled requests
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;
#endif


@end


#pragma mark Public interface methods

@implementation PNConnectionChannel


#pragma mark - Class methods

+ (PNConnectionChannel *)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType {
    
    return [[[self class] alloc] initWithType:connectionChannelType];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType {
    
    // Check whether intialization was successful or not
    if((self = [super init])) {
        
        // Retrieve connection idetifier based on connection channel type
        NSString *connectionIdentifier = PNConnectionIdentifiers.messagingConnection;
        if (connectionChannelType == PNConnectionChannelService) {
            
            connectionIdentifier = PNConnectionIdentifiers.serviceConnection;
        }
        
        
        // Initialize connection to the PubNub services
        self.connection = [PNConnection connectionWithIdentifier:connectionIdentifier];
        [self.connection assignDelegate:self];
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        self.connection.dataSource = [PNRequestsQueue sharedInstance];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
        self.requestsQueue = [PNRequestsQueue new];
        self.connection.dataSource = self.requestsQueue;
#endif  
        [self.connection connect];
    }
    
    
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED

- (void)scheduleRequest:(PNBaseRequest *)request {
    
    [[PNRequestsQueue sharedInstance] enqueueRequest:request];
}

- (void)unscheduleRequest:(PNBaseRequest *)request {
    
    [[PNRequestsQueue sharedInstance] removeRequest:request];
}

- (void)clearScheduledRequestsQueue {
    
    [[PNRequestsQueue sharedInstance] removeAllRequests];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
- (void)scheduleRequest:(PNBaseRequest *)request {
    
    [self.requestsQueue enqueueRequest:request];
}

- (void)unscheduleRequest:(PNBaseRequest *)request {
    
    [self.requestsQueue removeRequest:request];
}

- (void)clearScheduledRequestsQueue {
    
    [self.requestsQueue removeAllRequests];
}
#endif


#pragma mark - Connection delegate methods


#pragma mark - Memory management

- (void)dealloc {
    
    self.connection.dataSource = nil;
    [self.connection resignDelegate:self];
    [PNConnection destroyConnection:self.connection];
    self.connection = nil;
#if __MAC_OS_X_VERSION_MIN_REQUIRED
    self.requestsQueue = nil;
#endif
}

#pragma mark -


@end
