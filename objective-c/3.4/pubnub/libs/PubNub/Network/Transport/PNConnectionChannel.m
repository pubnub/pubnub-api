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

+ (PNConnectionChannel *)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType
                                       andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    return [[[self class] alloc] initWithType:connectionChannelType andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    // Check whether intialization was successful or not
    if((self = [super init])) {
        
        self.delegate = delegate;
        self.state = PNConnectionChannelStateCreated;
        
        
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
        [self connect];
    }
    
    
    return self;
}

- (void)connect {
    
    // Check whether is able to connect or not
    if([self.connection connect]) {
        
        self.state = PNConnectionChannelStateConnecting;
    }
    else {
        
        self.state = PNConnectionChannelStateDisconnected;
    }
}

- (BOOL)isConnected {
    
    return self.state == PNConnectionChannelStateConnected;
}

- (void)disconnect {
    
    self.state = PNConnectionChannelStateDisconnecting;
    
    [self.connection closeConnection];
}


#pragma mark - Requests queue management methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED

- (void)scheduleRequest:(PNBaseRequest *)request {
    
    if([[PNRequestsQueue sharedInstance] enqueueRequest:request]) {
        
        [self.connection scheduleNextRequestExecution];
    }
}

- (void)unscheduleRequest:(PNBaseRequest *)request {
    
    [[PNRequestsQueue sharedInstance] removeRequest:request];
}

- (void)clearScheduledRequestsQueue {
    
    [[PNRequestsQueue sharedInstance] removeAllRequests];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
- (void)scheduleRequest:(PNBaseRequest *)request {
    
    if([self.requestsQueue enqueueRequest:request]) {
        
        [self.connection scheduleNextRequestExecution];
    }
}

- (void)unscheduleRequest:(PNBaseRequest *)request {
    
    [self.requestsQueue removeRequest:request];
}

- (void)clearScheduledRequestsQueue {
    
    [self.requestsQueue removeAllRequests];
}
#endif


#pragma mark - Connection delegate methods

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {
    
    self.state = PNConnectionChannelStateConnected;
    
    
    [self.delegate connectionChannel:self didConnectToHost:hostName];
    
    // Launch communication process on sockets by triggering
    // requests queue processing
    [self.connection scheduleNextRequestExecution];
}

- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error {
    
    if (self.state != PNConnectionChannelStateDisconnectingOnError) {
    
        self.state = PNConnectionChannelStateDisconnectingOnError;
        
        
        [self.delegate connectionChannel:self willDisconnectFromOrigin:host withError:error];
    }
}

- (void)connection:(PNConnection *)connection connectionDidFailToHost:(NSString *)hostName withError:(PNError *)error {
    
    if (self.state != PNConnectionChannelStateDisconnected) {
    
        self.state = PNConnectionChannelStateDisconnected;
        
        
        // Check whether all streams closed or not
        // (in case if server closed only one from
        // read/write streams)
        if (![connection isDisconnected]) {
            
            [connection closeConnection];
        }
        else {
            
            [self.delegate connectionChannel:self connectionDidFailToOrigin:hostName withError:error];
        }
    }
}

- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName {
    
    if(self.state != PNConnectionChannelStateDisconnected) {
        
        self.state = PNConnectionChannelStateDisconnected;
        
        [self.delegate connectionChannel:self didDisconnectFromOrigin:hostName];
    }
}


#pragma mark - Memory management

- (void)dealloc {
    
#if __MAC_OS_X_VERSION_MIN_REQUIRED
    self.connection.dataSource = nil;
    self.requestsQueue = nil;
#endif
    
    if (self.state == PNConnectionChannelStateConnected) {
        
        [self.delegate connectionChannel:self didDisconnectFromOrigin:nil];
    }
    
    [self.connection resignDelegate:self];
    [PNConnection destroyConnection:self.connection];
    self.connection = nil;
}

#pragma mark -


@end
