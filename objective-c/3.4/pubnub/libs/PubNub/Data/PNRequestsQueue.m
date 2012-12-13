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
#import "PNBaseRequest.h"


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


#pragma mark - Instance methods

/**
 * Returns refference on request which is still not
 * processed by connection with specified identifier
 */
- (PNBaseRequest *)dequeueNextRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Returns identifier for next request which 
 * probably will be sent for processing
 */
- (NSString *)nextRequestIdentifier;


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
    }
    
    
    return self;
}


#pragma mark - Queue management

- (BOOL)enqueueRequest:(PNBaseRequest *)request {
    
    BOOL requestScheduled = NO;
    
    // Searching for existing request entry
    NSPredicate *sameObjectsSearch = [NSPredicate predicateWithFormat:@"identifier = %@ && processing = %@",
                                      request.identifier,
                                      @NO];
    if ([[self.query filteredArrayUsingPredicate:sameObjectsSearch] count] == 0) {
        
        [self.query addObject:request];
        requestScheduled = YES;
    }
    
    
    return requestScheduled;
}

- (PNBaseRequest *)dequeueNextRequestWithIdentifier:(NSString *)requestIdentifier {
    
    // Searching for existing request entry by it's identifier
    // which is not launched yet
    NSPredicate *nextRequestSearch = [NSPredicate predicateWithFormat:@"identifier = %@ && processing = %@",
                                      requestIdentifier,
                                      @NO];
    NSArray *filteredRequests = [self.query filteredArrayUsingPredicate:nextRequestSearch];
    
    
    return ([filteredRequests count] > 0 ? [filteredRequests lastObject] : nil);
}

- (void)removeRequest:(PNBaseRequest *)request {
    
    // Check whether request not in the processing
    // at this moment and remove it if possible
    if (!request.processing) {
        
        [self.query removeObject:request];
    }
}

- (void)removeAllRequests {
    
    // Find all requests which is not launched yet
    NSPredicate *inactiveRequestsSearch = [NSPredicate predicateWithFormat:@"processing = %@", @NO];
    NSArray *filteredRequests = [self.query filteredArrayUsingPredicate:inactiveRequestsSearch];
    
    
    if ([filteredRequests count] > 0) {
        
        // Remove all inactive requests
        [self.query removeObjectsInArray:filteredRequests];
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


#pragma mark - Connection data source methods

- (BOOL)hasDataForConnection:(PNConnection *)connection {
    
    return [self.query count] > 0;
}

- (NSString *)nextRequestIdentifierForConnection:(PNConnection *)connection {
    
    return [self nextRequestIdentifier];
}

- (NSData *)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier {
    
    return [[self dequeueNextRequestWithIdentifier:requestIdentifier] serializedMessage];
}

- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier {
    
    // Mark request as in processing state
    PNBaseRequest *currentRequest = [self dequeueNextRequestWithIdentifier:requestIdentifier];
    currentRequest.processing = YES;
}

- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier {
    
    // Find processed request by identifier to remove it from
    // requests queue
    [self removeRequest:[self dequeueNextRequestWithIdentifier:requestIdentifier]];
}

/**
 * Handle request send failure event to reset request state.
 * Maybe this error occurred because of network error, so we
 * should resend request right after connection is up again
 */
- (void)connection:(PNConnection *)connection failedToProcessRequestWithIdentifier:(NSString *)requestIdentifier {
    
    // Mark request as not in processing state
    PNBaseRequest *currentRequest = [self dequeueNextRequestWithIdentifier:requestIdentifier];
    currentRequest.processing = NO;
}


#pragma mark -


@end
