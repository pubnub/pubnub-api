//
//  PNRequestsQueue.m
//  pubnub
//
//  This class was created for iOS PubNub
//  client support to handle request sending
//  via single socket connection.
//  This is singleton class which will help
//  to organize requests into single FIFO
//  pipe.
//
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import "PNRequestsQueue.h"
#import "NSMutableArray+PNAdditions.h"
#import "PNBaseRequest.h"
#import "PNWriteBuffer.h"


#pragma mark Static

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static PNRequestsQueue *_sharedInstance = nil;
#endif

static NSUInteger const kPNRequestQueueNextRequestIndex = 0;


#pragma mark - Private interface methods

@interface PNRequestsQueue ()


#pragma mark - Properties

// Stores list of scheduled queries
@property (nonatomic, strong) NSMutableArray *query;

// Stores map of sender and their requests
@property (nonatomic, strong) NSMutableDictionary *requestsMap;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
// Stores list of connection delegates which would like to retrieve
// connection events
@property (nonatomic, strong) NSMutableArray *delegates;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
// Stores reference on connection delegate which also will
// be packet provider for connection
@property (nonatomic, pn_desired_weak) id<PNRequestsQueueDelegate> delegate;
#endif


#pragma mark - Instance methods

/**
 * Returns reference on request which is still not
 * processed by connection with specified identifier
 */
- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Returns identifier for next request which 
 * probably will be sent for processing
 */
- (NSString *)nextRequestIdentifier;

/**
 * Retrieve reference on the instance which issued specified request
 */
- (id<PNRequestsQueueDelegate>)delegateForRequest:(PNBaseRequest *)request;


@end


#pragma mark - Public interface methods

@implementation PNRequestsQueue


#pragma mark Class methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
+ (PNRequestsQueue *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
    
    
    return _sharedInstance;
}
#endif


#pragma mark - Instance methods

- (id)init {
    
    // Check whether intialization successful or not
    if((self = [super init])) {
        
        self.query = [NSMutableArray array];
        self.requestsMap = [NSMutableDictionary dictionary];
    }
    
    
    return self;
}


#pragma mark - Queue management

- (BOOL)enqueueRequest:(PNBaseRequest *)request sender:(id)sender {
    
    BOOL requestScheduled = NO;
    
    // Searching for existing request entry
    NSPredicate *sameObjectsSearch = [NSPredicate predicateWithFormat:@"identifier = %@ && processing = %@",
                                      request.identifier,
                                      @NO];
    if ([[self.query filteredArrayUsingPredicate:sameObjectsSearch] count] == 0) {
        
        [self.query addObject:request];
        
        // Map request to the sender
        NSString *senderName = NSStringFromClass([sender class]);
        if([self.requestsMap valueForKey:senderName] == nil) {
            
            [self.requestsMap setValue:[NSMutableArray array] forKey:senderName];
        }
        [[self.requestsMap valueForKey:senderName] addObject:request];
        
        requestScheduled = YES;
    }
    
    
    return requestScheduled;
}

- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier {
    
    // Searching for existing request entry by it's identifier
    // which is not launched yet
    NSPredicate *nextRequestSearch = [NSPredicate predicateWithFormat:@"identifier = %@", requestIdentifier];
    NSArray *filteredRequests = [self.query filteredArrayUsingPredicate:nextRequestSearch];
    
    
    return ([filteredRequests count] > 0 ? [filteredRequests lastObject] : nil);
}

- (void)removeRequest:(PNBaseRequest *)request {
    
    // Check whether request not in the processing
    // at this moment and remove it if possible
    if (!request.processing) {
        
        [self.query removeObject:request];
        
        
        // Remove request from sender-request mapping table
        __block NSMutableArray *requestHoldingArray = nil;
        [self.requestsMap enumerateKeysAndObjectsUsingBlock:^(id sender,
                                                              NSMutableArray *requests,
                                                              BOOL *senderEnumeratorStop) {
            
            if([requests containsObject:request]) {
                
                requestHoldingArray = requests;
                *senderEnumeratorStop = YES;
            }
        }];
        
        [requestHoldingArray removeObject:request];
    }
}

- (void)removeAllRequestsFromSender:(id)sender {
    
    // Find all requests which is not launched yet
    NSPredicate *inactiveRequestsSearch = [NSPredicate predicateWithFormat:@"processing = %@", @NO];
    NSArray *filteredRequests = [self.query filteredArrayUsingPredicate:inactiveRequestsSearch];
    
    
    if ([filteredRequests count] > 0) {
        
        // Remove all inactive requests sent by particular
        // sender
        NSString *senderName = NSStringFromClass([sender class]);
        [[self.requestsMap valueForKey:senderName] removeObjectsInArray:filteredRequests];
    }
}

- (NSString *)nextRequestIdentifier {
    
    NSString *nextRequestIndex = nil;
    
    if ([self.query count] > 0) {
        
        PNBaseRequest *nextRequest = (PNBaseRequest *)[self.query objectAtIndex:kPNRequestQueueNextRequestIndex];
        nextRequestIndex = [nextRequest identifier];
    }
    
    
    return nextRequestIndex;
}

- (id<PNRequestsQueueDelegate>)delegateForRequest:(PNBaseRequest *)request {

    __block id<PNRequestsQueueDelegate> delegateForRequest = nil;
    __block NSString *delegateClassName = nil;

    // Searching name for delegate which issued specified request
    [self.requestsMap enumerateKeysAndObjectsUsingBlock:^(NSString *delegateName,
                                                          NSArray *delegateRequests,
                                                          BOOL *delegatesEnumeratorStop) {
        if ([delegateRequests containsObject:request]) {

            delegateClassName = delegateName;
            *delegatesEnumeratorStop = YES;
        }
    }];

    [[self delegates] enumerateObjectsUsingBlock:^(id delegate, NSUInteger delegateIdx, BOOL *delegateEnumeratorStop) {

        if ([NSStringFromClass([delegate class]) isEqual:delegateClassName]) {

            delegateForRequest = delegate;
            *delegateEnumeratorStop = YES;
        }
    }];


    return delegateForRequest;
}


#pragma mark - Misc methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)assignDelegate:(id<PNRequestsQueueDelegate>)delegate {

    [[self delegates] addObject:delegate];
}

- (void)resignDelegate:(id<PNRequestsQueueDelegate>)delegate {

    [[self delegates] removeObject:delegate];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
- (void)assignDelegate:(id<PNRequestsQueueDelegate>)delegate {

    self.delegate = delegate;
}

- (void)resignDelegate:(id<PNRequestsQueueDelegate>)delegate {

    self.delegate = nil;
}
#endif

/**
 * Reloading property to handle connection instance
 * to have multiple delegates when running on iOS and
 * only one delegate on Mac OS
 */
- (NSMutableArray *)delegates {

    NSMutableArray *delegates = nil;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    if (_delegates == nil) {

        _delegates = [NSMutableArray arrayUsingWeakReferences];
    }


    delegates = _delegates;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    delegates = @[self.delegate];
#endif


    return delegates;
}


#pragma mark - Connection data source methods

- (BOOL)hasDataForConnection:(PNConnection *)connection {
    
    return [self.query count] > 0;
}

- (NSString *)nextRequestIdentifierForConnection:(PNConnection *)connection {
    
    return [self nextRequestIdentifier];
}

- (PNWriteBuffer *)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier {

    // Retrieve reference on next request which will be processed
    PNBaseRequest *nextRequest = [self dequeRequestWithIdentifier:requestIdentifier];
    PNWriteBuffer *buffer = nil;

    // Check whether request already processed or not
    // (processed requests can be leaved in queue to
    // lock it's further execution till specific event
    // or timeout)
    if (!nextRequest.processed) {

        buffer = [nextRequest buffer];
    }


    return buffer;
}

- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier {
    
    // Mark request as in processing state
    PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];

    if (currentRequest != nil) {

        // Forward request processing start to request issuer
        [[self delegateForRequest:currentRequest] requestsQueue:self willSendRequest:currentRequest];
    }
}

- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier {
    
    PNBaseRequest *processedRequest = [self dequeRequestWithIdentifier:requestIdentifier];
    
    if (processedRequest != nil) {

        id<PNRequestsQueueDelegate> delegate = [self delegateForRequest:processedRequest];

        // Forward request processing completion to request issuer
        [delegate requestsQueue:self didSendRequest:processedRequest];


        // Check whether request issuer allow to remove completed request from queue
        // or should leave it there and lock queue with it
        if ([delegate shouldRequestsQueue:self removeCompletedRequest:processedRequest]) {

            // Find processed request by identifier to remove it from
            // requests queue
            [self removeRequest:[self dequeRequestWithIdentifier:requestIdentifier]];
        }
    }
}

- (void)connection:(PNConnection *)connection didCancelRequestWithIdentifier:(NSString *)requestIdentifier {

    // Forward request cancellation event to request issuer
    PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];

    if (currentRequest != nil) {

        [[self delegateForRequest:currentRequest] requestsQueue:self didCancelRequest:currentRequest];
    }
}

/**
 * Handle request send failure event to reset request state.
 * Maybe this error occurred because of network error, so we
 * should resend request right after connection is up again
 */
- (void)connection:(PNConnection *)connection
        didFailToProcessRequestWithIdentifier:(NSString *)requestIdentifier
         withError:(PNError *)error {
    
    // Mark request as not in processing state
    PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];

    if (currentRequest != nil) {

        // Forward request processing failure to request issuer
        [[self delegateForRequest:currentRequest] requestsQueue:self didFailRequestSend:currentRequest withError:error];
    }
}


#pragma mark - Memory management

- (void)dealloc {

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    _delegates = nil;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    _delegate = nil;
#endif
}

#pragma mark -


@end
