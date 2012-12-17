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

#import "PubNub+Protected.h"
#import "PNConnectionChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "PNMessagingChannel.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNNotifications.h"
#import "PNReachability.h"
#import "PNConnection.h"
#import "PNError.h"
#import "PNMacro.h"


#pragma mark Static

// Stores reference on singleton PubNub instance
static PubNub *_sharedInstance = nil;


#pragma mark - Private interface methods

@interface PubNub () <PNConnectionChannelDelegate>


#pragma mark - Properties

// Stores reference on flag which specufy whether client
// identifier was passed by user or generated on demand
@property (nonatomic, assign, getter = isUserProvidedClientIdentifier) BOOL userProvidedClientIdentifier;

// Stores whether client should connect as soon as services
// will be checked for reachability
@property (nonatomic, assign, getter = shouldConnectOnServiceReachabilityCheck) BOOL connectOnServiceReachabilityCheck;

// Check whether PubNub client completed intialization or not
// (full initialization cycle is from configuration to time token
// retrival from PubNub services)
@property (nonatomic, assign, getter = isInitialized) BOOL initialized;

// Stores reference on configuration which was used to
// perform intial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *temporaryConfiguration;

// Reference on channels which is used to communicate
// with PubNub service
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

// Stores reference on client delegate
@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;

// Stores unique client intialization session identifier
// (created each time when PubNub stack is configured
// after application launch)
@property (nonatomic, strong) NSString *launchSessionIdentifier;

// Reference on channels which is used to send service
// messages to PubNub service
@property (nonatomic, strong) PNServiceChannel *serviceChannel;

// Stores reference on configuration which was used to
// perform intial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on service reachability monitoring
// instance
@property (nonatomic, strong) PNReachability *reachability;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;

// Stores current client state
@property (nonatomic, assign) PNPubNubClientState state;


#pragma mark - Instance methods

+ (void)disconnectForConfigurationChange;


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


#pragma mark - Handler methods

/**
 * Handling error which occurred while PubNub client
 * tried establish connection and lost internet connection
 */
- (void)handleConnectionErrorOnNetworkFailure;


#pragma mark - Misc methods

/**
 * This method allow to ensure that delegate can
 * process errors and will send error to the
 * delegate
 */
- (void)notifyDelegateAboutError:(PNError *)error;


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
    
    // Check whether instance already connected or not
    if ([self sharedInstance].state == PNPubNubClientStateConnected ||
        [self sharedInstance].state == PNPubNubClientStateConnecting) {
        
        [[self sharedInstance] notifyDelegateAboutError:[PNError errorWithCode:kPNClientConnectWhileConnected]];
    }
    else {
        
        if ([self sharedInstance].configuration == nil) {
            
            [[self sharedInstance] notifyDelegateAboutError:[PNError errorWithCode:kPNClientConfigurationError]];
        }
        else {
            
            [self sharedInstance].connectOnServiceReachabilityCheck = NO;
            
            
            // Check whether services are available or not
            if ([[self sharedInstance].reachability isServiceReachabilityChecked]) {
                
                if ([[self sharedInstance].reachability isServiceAvailable]) {
                    
                    // Check whether user identifier was provided by
                    // user or not
                    if(![self sharedInstance].isUserProvidedClientIdentifier) {
                        
                        // Change user identifier before connect to the
                        // PubNub services
                        [self sharedInstance].clientIdentifier = PNNewUniqueIdentifier();
                    }
                    
                    
                    if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:willConnectToOrigin:)]) {
                        
                        [[self sharedInstance].delegate performSelector:@selector(pubnubClient:willConnectToOrigin:)
                                                             withObject:[self sharedInstance]
                                                             withObject:[self sharedInstance].configuration.origin];
                    }
                    
                    
                    if ([self sharedInstance].state == PNPubNubClientStateCreated) {
                        
                        [self sharedInstance].state = PNPubNubClientStateConnecting;
                        
                        [self sharedInstance].messagingChannel = [PNMessagingChannel new];
                        [self sharedInstance].serviceChannel = [PNServiceChannel new];
                        [self sharedInstance].messagingChannel.delegate = [self sharedInstance];
                        [self sharedInstance].serviceChannel.delegate = [self sharedInstance];
                    }
                    else {
                        
                        [self sharedInstance].state = PNPubNubClientStateConnecting;
                        
                        [[self sharedInstance].messagingChannel connect];
                        [[self sharedInstance].serviceChannel connect];
                    }
                    
                    
                    [[self sharedInstance] warmUpConnection];
                }
                else {
                    
                    [[self sharedInstance] handleConnectionErrorOnNetworkFailure];
                }
            }
            else {
                
                [self sharedInstance].connectOnServiceReachabilityCheck = YES;
            }
        }
    }
}

+ (void)disconnect {
    
    [self sharedInstance].state = PNPubNubClientStateDisconnecting;
    
    
    // Empty connection pool after connection will
    // be closed
    [PNConnection closeAllConnections];
    
    
    // Clean up
    [self sharedInstance].messagingChannel = nil;
    [self sharedInstance].serviceChannel = nil;
}

+ (void)disconnectForConfigurationChange {
    
    [self sharedInstance].state = PNPubNubClientStateDisconnectingOnConfigurationChange;
    
    
    // Empty connection pool after connection will
    // be closed
    [PNConnection closeAllConnections];
}


#pragma mark - Client configuration methods

+ (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:[self sharedInstance].delegate];
}

+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    // Ensure that configuration is valid before update/set
    // cient configuration to it
    if ([configuration isValid]) {
        
        [self setDelegate:delegate];
        
        
        // Ensure that PubNub client not connected to remote
        // PubNub services
        if (![[self sharedInstance] isConnected]) {
            
            [self sharedInstance].configuration = configuration;
        }
        // Looks like client already connected, perform
        // hard reset
        else {
            
            // Store new configuration while client is disconnecting
            [self sharedInstance].temporaryConfiguration = configuration;
            
            
            // Disconnect befor client configuration upate
            [self disconnectForConfigurationChange];
        }
        
        [[self sharedInstance].reachability startServiceReachabilityMonitoring];
    }
    else {
        
        [[self sharedInstance] notifyDelegateAboutError:[PNError errorWithCode:kPNClientConfigurationError]];
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
        if(![clientIdentifier isEqualToString:identifier]) {
            
            if (clientIdentifier == nil) {
                
                [self sharedInstance].userProvidedClientIdentifier = NO;
            }
            
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
        
        self.state = PNPubNubClientStateCreated;
        self.launchSessionIdentifier = PNNewUniqueIdentifier();
        self.reachability = [PNReachability serviceReachability];
        
        // Adding PubNub services availability observer
        __block __pn_desired_weak PubNub *weakSelf = self;
        self.reachability.reachabilityChangeHandleBlock = ^(BOOL connected) {
            
            if (weakSelf.shouldConnectOnServiceReachabilityCheck) {
                    
                [[weakSelf class] connect];
            }
            else {
                
                if (connected) {
                    
                    if (weakSelf.state == PNPubNubClientStateDisconnectedOnNetworkError) {
                        
                        BOOL shouldRestoreConnection = self.configuration.shouldAutoReconnectClient;
                        if ([weakSelf.delegate respondsToSelector:@selector(shouldReconnectPubNubClient:)]) {
                            
                            shouldRestoreConnection = [[self.delegate performSelector:@selector(shouldReconnectPubNubClient:)
                                                                           withObject:weakSelf] boolValue];
                        }
                        
                        
                        // Check whether should restore connection or not
                        if(shouldRestoreConnection) {
                            
                            NSLog(@"RESTORE CONNECTION");
                            
                            [[weakSelf class] connect];
                        }
                    }
                }
                else {
                    
                    // Check whether PubNub client was connected or connecting right now
                    if (weakSelf.state == PNPubNubClientStateConnected || weakSelf.state == PNPubNubClientStateConnecting) {
                        
                        if (weakSelf.state == PNPubNubClientStateConnecting) {
                            
                            [weakSelf handleConnectionErrorOnNetworkFailure];
                        }
                        else {
                            
                            NSLog(@"DISCONNECT CONNECTION CHANNELS");
                            
                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            
                            [weakSelf.messagingChannel disconnect];
                            [weakSelf.serviceChannel disconnect];
                        }
                    }
                }
            }
        };
    }
    
    
    return self;
}


#pragma mark - Client connection management methods

- (BOOL)isConnected {
    
    return self.state == PNPubNubClientStateConnected;
}

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
    
    
    // Checking whether request should be sent on service
    // connection channel or not
    if ([request isKindOfClass:[PNLeaveRequest class]] ||
        [request isKindOfClass:[PNTimeTokenRequest class]] ||
        [request isKindOfClass:[PNLatencyMeasureRequest class]]) {
        
        shouldSendOnMessageChannel = NO;
    }
    
    
    [self sendRequest:request onChannel:(shouldSendOnMessageChannel?self.messagingChannel:self.serviceChannel)];
}

- (void)sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel {
    
    [channel scheduleRequest:request];
}


#pragma mark - Connection channel delegate methods

- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host {
    
    // Check whether all communication channels connected and whether
    // client in corresponding state or not
    if ([self.messagingChannel isConnected] && [self.serviceChannel isConnected] &&
        self.state == PNPubNubClientStateConnecting && [self.configuration.origin isEqualToString:host]) {
        
        // Mark that PubNub client established connection to PubNub
        // services
        self.state = PNPubNubClientStateConnected;
        
        
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didConnectToOrigin:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didConnectToOrigin:)
                                withObject:self
                                withObject:self.configuration.origin];
        }
        
        
        // Send notification to all who is interested in it
        // (observation center will track it as well)
        [[NSNotificationCenter defaultCenter] postNotificationName:kPNClientDidConnectToOriginNotification
                                                            object:self
                                                          userInfo:(id)host];
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel
     connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error {
    
    // Check whether client in corresponding state and all
    // communication channels not connected to the server
    if(self.state == PNPubNubClientStateConnecting && [self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {
        
        if ([self.delegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:connectionDidFailWithError:)
                                withObject:self
                                withObject:error];
        }
        
        
        // Send notification to all who is interested in it
        // (observation center will track it as well)
        [[NSNotificationCenter defaultCenter] postNotificationName:kPNClientConnectionDidFailWithErrorNotification
                                                            object:self
                                                          userInfo:(id)error];
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host {
    
    // Check whether host name arrived or not
    // (it may not arrive if event sending instance
    // was dismissed/deallocated)
    if (host == nil) {
        
        host = self.configuration.origin;
    }
    
    
    // Check whether recieved event from same host on which client
    // is configured or not and all communication channels are closed
    if([self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {
        
        // Check whether all communication channels disconnected and whether
        // client in corresponding state or not
        if (self.state == PNPubNubClientStateDisconnecting ||
            self.state == PNPubNubClientStateDisconnectingOnNetworkError) {
            
            PNPubNubClientState state = PNPubNubClientStateDisconnected;
            if (self.state == PNPubNubClientStateDisconnectingOnNetworkError) {
                
                state = PNPubNubClientStateDisconnectedOnNetworkError;
            }
            self.state = state;
            
            
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didDisconnectFromOrigin:)
                                    withObject:self
                                    withObject:host];
            }
            
            
            // Send notification to all who is interested in it
            // (observation center will track it as well)
            [[NSNotificationCenter defaultCenter] postNotificationName:kPNClientDidDisconnectFromOriginNotification
                                                                object:self
                                                              userInfo:(id)host];
        }
        // Check whether server unexpectedly closed connection
        // while client was active or not
        else if(self.state == PNPubNubClientStateConnected) {
            
            PNLog(@"TRY TO RESTORE CONNECTION");
            
            self.state = PNPubNubClientStateDisconnected;
            
            
            // Try to restore connection to remote PubNub services
            [[self class] connect];
        }
        // Check whether connection has been closed because
        // PubNub client updates it's configuration
        else if (self.state == PNPubNubClientStateDisconnectingOnConfigurationChange) {
            
            [[self class] disconnect];
            
            
            // Delay connection restore to give some time internal
            // components to complete their tasks
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                self.state = PNPubNubClientStateCreated;
                self.configuration = self.temporaryConfiguration;
                self.temporaryConfiguration = nil;
                
                // Restore connection which will use new configuration
                [[self class] connect];
            });
        }
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel
    willDisconnectFromOrigin:(NSString *)host
                withError:(PNError *)error {
    
    if (self.state == PNPubNubClientStateConnected && [self.configuration.origin isEqualToString:host] &&
        ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {
        
        self.state = PNPubNubClientStateDisconnecting;
        if (![self.reachability isServiceAvailable]) {
            
            self.state = PNPubNubClientStateDisconnectingOnNetworkError;
        }
        
        
        if ([self.delegate respondsToSelector:@selector(pubnubClient:willDisconnectWithError:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:willDisconnectWithError:)
                                withObject:self
                                withObject:error];
        }
        
        
        // Send notification to all who is interested in it
        // (observation center will track it as well)
        [[NSNotificationCenter defaultCenter] postNotificationName:kPNClientConnectionDidFailWithErrorNotification
                                                            object:self
                                                          userInfo:(id)error];
    }
}


#pragma mark - Handler methods

- (void)handleConnectionErrorOnNetworkFailure {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:connectionDidFailWithError:)
                            withObject:self
                            withObject:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailure]];
    }
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutError:(PNError *)error {
        
    if ([self.delegate respondsToSelector:@selector(pubnubClient:error:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:error:)
                            withObject:self
                            withObject:error];
    }
}

#pragma mark -


@end
