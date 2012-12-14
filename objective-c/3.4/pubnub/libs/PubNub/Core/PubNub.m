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
#import "PNMessagingChannel.h"
#import "PNConnection+Protected.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNConnection.h"
#import "PNMacro.h"


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

// Reference on channels which is used to communicate
// with PubNub service
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

// Reference on channels which is used to send service
// messages to PubNub service
@property (nonatomic, strong) PNMessagingChannel *serviceChannel;

// Stores reference on configuration which was used to
// perform intial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;

// Stores unique client intialization session identifier
// (created each time when PubNub stack is configured
// after application launch)
@property (nonatomic, strong) NSString *launchSessionIdentifier;

// Stores reference on client delegate
@property (nonatomic, unsafe_unretained) id<PNDelegate> delegate;


#pragma mark - Instance methods

#pragma mark - Client connection management methods

/**
 * This method allow to schedule intial requests on
 * connections to tell server that we are really
 * interested in persistent connection
 */
- (void)warmUpConnection;


#pragma mark - Requests management methods

/**
 * Sends message over corresponding communication
 * channel
 */
- (void)sendRequest:(PNBaseRequest *)request;

/**
 * Send message over specified communication channel
 */
- (void)sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel;


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
    
    
    // Check whether user identifier was provided by
    // user or not
    if(![self sharedInstance].isUserProvidedClientIdentifier) {
        
        // Change user identifier before connect to the
        // PubNub services
        [self sharedInstance].clientIdentifier = newUniqueIdentifier();
    }
    
    
    [self sharedInstance].messagingChannel = [PNMessagingChannel new];
    [self sharedInstance].serviceChannel = [PNMessagingChannel new];
    
    
    [[self sharedInstance] warmUpConnection];
}

+ (void)disconnect {
    
    // Clean up
    [self sharedInstance].messagingChannel = nil;
    
    
    [PNConnection closeAllConnections];
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


#pragma mark - Instance methods

- (id)init {
    
    // Check whether intialization successful or not
    if((self = [super init])) {
        
        self.launchSessionIdentifier = newUniqueIdentifier();
    }
    
    
    return self;
}

#pragma mark - Client connection management methods

- (void)warmUpConnection {
    
    [self sendRequest:[PNTimeTokenRequest new] onChannel:self.messagingChannel];
#if __MAC_OS_X_VERSION_MIN_REQUIRED
    [self sendRequest:[PNTimeTokenRequest new] onChannel:self.serviceChannel];
#endif
}

- (void)requestServerTimeToken {
    
    [self sendRequest:[PNTimeTokenRequest new]];
}

- (void)sendRequest:(PNBaseRequest *)request {
    
    BOOL shouldSendOnMessageChannel = YES;
    
    
    
    
    if (shouldSendOnMessageChannel) {
        
        [self sendRequest:request onChannel:self.messagingChannel];
    }
}

- (void)sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel {
    
    [channel scheduleRequest:request];
}

#pragma mark -


@end
