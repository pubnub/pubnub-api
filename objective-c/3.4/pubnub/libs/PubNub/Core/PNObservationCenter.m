//
//  PNObservationCenter.h
//  pubnub
//
//  Observation center will allow to subscribe
//  for particular events with handle block
//  (block will be provided by subscriber)
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import "PNObservationCenter.h"
#import "NSMutableDictionary+PNAdditions.h"


#pragma mark Static

// Stores reference on shared observation center instance
static PNObservationCenter *_sharedInstance = nil;

struct PNObservationEventsStruct {
    
    __unsafe_unretained NSString *clientConnectionStateChange;
};

static struct PNObservationEventsStruct PNObservationEvents = {
    
    .clientConnectionStateChange = @"clientConnectionStateChange"
};


#pragma mark - Private interface methods

@interface PNObservationCenter ()


#pragma mark - Properties

// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
@property (nonatomic, strong) NSMutableDictionary *observers;


#pragma mark - Instance methods

/**
 * Managing observation list
 */
- (void)addObserver:(id)observer forEvent:(NSString *)eventName withBlock:(id)block;
- (void)removeObserver:(id)observer forEvent:(NSString *)eventName;

@end


#pragma mark - Public interface methods

@implementation PNObservationCenter


#pragma mark Class methods

+ (void)defaultCenter {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
}

- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientConnectionStateChange withBlock:callbackBlock];
}

- (void)removeClientConnectionStateObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientConnectionStateChange];
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        // Configure dictionary which wouldn't retain it's value and keys
        self.observers = [NSMutableDictionary dictionary];
    }
    
    
    return self;
}

- (void)addObserver:(id)observer forEvent:(NSString *)eventName withBlock:(id)block {
    
    if ([self.observers valueForKey:eventName] == nil) {
        
        [self.observers setValue:[NSMutableDictionary dictionaryWithNonRetainedValuesAndKeys] forKey:eventName];
    }
    
    [[self.observers valueForKey:eventName] setValue:block forKey:NSStringFromClass([observer class])];
}

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName {
    
    if ([self.observers valueForKey:eventName] != nil) {
        
        [[self.observers valueForKey:eventName] removeObjectForKey:NSStringFromClass([observer class])];
    }
}


#pragma mark -

@end
