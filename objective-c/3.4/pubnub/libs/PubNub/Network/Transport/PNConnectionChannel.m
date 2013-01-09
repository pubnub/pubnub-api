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
#import "PubNub+Protected.h"
#import "PNRequestsQueue.h"


#pragma mark Private interface methods

@interface PNConnectionChannel () <PNConnectionDelegate>


#pragma mark - Properties

// Stores reference on connection which is used
// as transport layer to send messages to the
// PubNub service
@property (nonatomic, strong) PNConnection *connection;

#if __MAC_OS_X_VERSION_MIN_REQUIRED
// Stores reference on array of scheduled requests
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;
#endif

// Stores reference on all requests on which we are waiting
// for response
@property (nonatomic, strong) NSMutableDictionary *observedRequests;


@end


#pragma mark Public interface methods

@implementation PNConnectionChannel


#pragma mark - Class methods

+ (id)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType
                      andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    return [[[self class] alloc] initWithType:connectionChannelType andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.delegate = delegate;
        self.state = PNConnectionChannelStateCreated;
        self.observedRequests = [NSMutableDictionary dictionary];
        
        
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
        [[PNRequestsQueue sharedInstance] assignDelegate:self];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
        self.requestsQueue = [PNRequestsQueue new];
        self.connection.dataSource = self.requestsQueue;
        [self.requestsQueue assignDelegate:self];
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

- (BOOL)isWaitingRequestCompletion:(NSString *)requestIdentifier {
    
    BOOL isWaitingRequestCompletion = NO;
    
    if(requestIdentifier != nil) {
        
        isWaitingRequestCompletion = [self.observedRequests objectForKey:requestIdentifier] != nil;
    }
    
    
    return isWaitingRequestCompletion;
}

- (void)purgeObservedRequestsPool {
    
    [self.observedRequests removeAllObjects];
}

- (PNBaseRequest *)observedRequestWithIdentifier:(NSString *)identifier {
    
    PNBaseRequest *request = nil;
    if(identifier != nil) {
        
        request = [self.observedRequests valueForKey:identifier];
    }
    
    
    return request;
}

- (void)removeObservationFromRequest:(PNBaseRequest *)request {
    
    if(request != nil) {
        
        [self.observedRequests removeObjectForKey:request.shortIdentifier];
    }
}

- (void)destroyRequest:(PNBaseRequest *)request {

    [self unscheduleRequest:request];
    [self removeObservationFromRequest:request];
}


#pragma mark - Requests queue management methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    if([[PNRequestsQueue sharedInstance] enqueueRequest:request sender:self]) {
        
        if (shouldObserveProcessing) {
            
            [self.observedRequests setValue:request forKey:request.shortIdentifier];
        }
        
        [self scheduleNextRequest];
    }
}

- (void)scheduleNextRequest {

    [self.connection scheduleNextRequestExecution];
}

- (void)unscheduleNextRequest {

    [self.connection unscheduleRequestsExecution];
}

- (void)unscheduleRequest:(PNBaseRequest *)request {
    
    [[PNRequestsQueue sharedInstance] removeRequest:request];
}

- (void)reconnect {

    [self.connection reconnect];
}

- (void)clearScheduledRequestsQueue {
    
    [[PNRequestsQueue sharedInstance] removeAllRequestsFromSender:self];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    if([self.requestsQueue enqueueRequest:request sender:self]) {
        
        if (shouldObserveProcessing) {
            
            [self.observedRequests setValue:request forKey:request.shortIdentifier];
        }
        
        [self scheduleNextRequest];
    }
}

- (void)scheduleNextRequest {

    [self.connection scheduleNextRequestExecution];
}

- (void)unscheduleNextRequest {

    [self.connection unscheduleRequestsExecution];
}

- (void)unscheduleRequest:(PNBaseRequest *)request {
    
    [self.requestsQueue removeRequest:request];
}

- (void)clearScheduledRequestsQueue {
    
    [self.requestsQueue removeAllRequestsFromSender:self];
}
#endif


#pragma mark - Connection delegate methods

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {
    
    self.state = PNConnectionChannelStateConnected;
    
    
    [self.delegate connectionChannel:self didConnectToHost:hostName];
    
    // Launch communication process on sockets by triggering
    // requests queue processing
    [self scheduleNextRequest];
}

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error {
    
    if (self.state != PNConnectionChannelStateDisconnectingOnError) {
    
        self.state = PNConnectionChannelStateDisconnectingOnError;
        
        [self unscheduleNextRequest];
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


        [self unscheduleNextRequest];
        [self.delegate connectionChannel:self connectionDidFailToOrigin:hostName withError:error];
    }
}

- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName {
    
    if(self.state != PNConnectionChannelStateDisconnected) {
        
        self.state = PNConnectionChannelStateDisconnected;


        [self unscheduleNextRequest];
        [self.delegate connectionChannel:self didDisconnectFromOrigin:hostName];
    }
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = YES;
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = NO;
    request.processed = YES;
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Updating request state
    request.processing = NO;

    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        // Increase request retry count
        [request increaseRetryCount];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = NO;
    [request resetRetryCount];
}

- (BOOL)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request {

    return YES;
}


#pragma mark - Memory management

- (void)dealloc {
    
    // Remove all requests sent by this communication
    // channel
    [self clearScheduledRequestsQueue];

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    [[PNRequestsQueue sharedInstance] resignDelegate:self];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    self.connection.dataSource = nil;
    [self.requestsQueue resignDelegate:self];
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
