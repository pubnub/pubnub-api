//
//  PubNub.m
//  pubnub
//
//  This is base and main class which is
//  responsible for communication with
//  PubNub services and handle all events
//  and notifications.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PubNub.h"
#import "PubNub+Protected.h"


#pragma mark Static

// Stores reference on singleton PubNub instance
static PubNub *_sharedInstance = nil;


#pragma mark - Private interface methods

@interface PubNub ()


#pragma mark - Properties

// Stores reference on flag which specufy whether client
// identifier was passed by user or generated on demand
@property (nonatomic, assign, getter = isUserProvidedClientIdentifier) BOOL userProvidedClientIdentifier;

// Check whether PubNub client completed intialization or not
// (full initialization cycle is from configuration to time token
// retrival from PubNub services)
@property (nonatomic, assign, getter = isInitialized) BOOL initialized;

// Stores reference on configuration which was used to
// perform intial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;

// Stores reference on client delegate
@property (nonatomic, weak) id<PNDelegate> delegate;


@end


#pragma mark - Public interface methods

@implementation PubNub


#pragma mark - Class methods

+ (PubNub *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
    
    
    return _sharedInstance;
}


#pragma mark - Client connection management methods

+ (void)connect {
    
    NSAssert([self sharedInstance].configuration!=nil, @"{ERROR} PubNub client configuration is required before connection.");
}


#pragma mark - Client configuration methods

+ (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:nil];
}

+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    NSAssert1([configuration isValid], @"{ERROR} Wrong or incompleted configuration has been passed to PubNumb client: %@",
              configuration);
    
    [self setDelegate:delegate];
    
    if (![self sharedInstance].isInitialized) {
        
        [[self sharedInstance] setConfiguration:configuration];
    }
    else {
        // TODO: PERFORM HARD RESET
    }
}

+ (void)setDelegate:(id<PNDelegate>)delegate {
    
    [self sharedInstance].delegate = delegate;
}


#pragma mark - Client identification methods

+ (void)setClientIdentifier:(NSString *)identifier {
    
    // Check whether identifier has beeen changed since last
    // method call or not
    if([self sharedInstance].isInitialized) {
        
        NSString *clientIdentifier = [self sharedInstance].clientIdentifier;
        if(clientIdentifier != nil && ![clientIdentifier isEqualToString:identifier]) {
            
            // TODO: SEND LEAVE EVENT TO THE PRESENCE API
            //       AND RE-SUBSCRIBE TO SPECIFIED CHANNELS
        }
    }
    else {
        
        [self sharedInstance].clientIdentifier = identifier;
        [self sharedInstance].userProvidedClientIdentifier = YES;
    }
}

+ (NSString *)clientIdentifier {
    
    NSString *identifier = [self sharedInstance].clientIdentifier;
    if (identifier == nil) {
        
        [self sharedInstance].userProvidedClientIdentifier = NO;
    }
    
    
    return [self sharedInstance].clientIdentifier;
}

#pragma mark -


@end
