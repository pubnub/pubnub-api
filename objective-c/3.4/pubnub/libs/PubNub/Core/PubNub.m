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
//  Created by Sergey Mamontov.
//
//

#import "PubNub+Protected.h"
#import "PNObservationCenter+Protected.h"
#import "PNConnectionChannelDelegate.h"
#import "PNPresenceEvent+Protected.h"
#import "PNServiceChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"
#import "PNMessagingChannel.h"
#import "PNError+Protected.h"
#import "PNServiceChannel.h"
#import "PNRequestsImport.h"
#import "PNHereNowRequest.h"


#pragma mark Static

// Stores reference on singleton PubNub instance
static PubNub *_sharedInstance = nil;


#pragma mark - Private interface methods

@interface PubNub () <PNConnectionChannelDelegate, PNMessageChannelDelegate, PNServiceChannelDelegate>


#pragma mark - Properties

// Stores reference on flag which specufy whether client
// identifier was passed by user or generated on demand
@property (nonatomic, assign, getter = isUserProvidedClientIdentifier) BOOL userProvidedClientIdentifier;

// Stores whether client should connect as soon as services
// will be checked for reachability
@property (nonatomic, assign, getter = shouldConnectOnServiceReachabilityCheck) BOOL connectOnServiceReachabilityCheck;

// Stores whether client is restoring connection after
// network failure or not
@property (nonatomic, assign, getter = isRestoringConnection) BOOL restoringConnection;

// Stores reference on configuration which was used to
// perform initial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *temporaryConfiguration;

// Reference on channels which is used to communicate
// with PubNub service
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

// Stores reference on client delegate
@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;

// Stores unique client initialization session identifier
// (created each time when PubNub stack is configured
// after application launch)
@property (nonatomic, strong) NSString *launchSessionIdentifier;

// Reference on channels which is used to send service
// messages to PubNub service
@property (nonatomic, strong) PNServiceChannel *serviceChannel;

// Stores reference on configuration which was used to
// perform initial PubNub client initialization
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
 * Configure client connection state observer with 
 * handling blocks
 */
- (void)setClientConnectionObservationWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                                          failureBlock:(PNClientConnectionFailureBlock)failure;

/**
 * This method allow to schedule initial requests on
 * connections to tell server that we are really
 * interested in persistent connection
 */
- (void)warmUpConnection;


#pragma mark - Requests management methods

/**
 * Sends message over corresponding communication
 * channel
 */
- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing;;

/**
 * Send message over specified communication channel
 */
- (void)    sendRequest:(PNBaseRequest *)request
              onChannel:(PNConnectionChannel *)channel
shouldObserveProcessing:(BOOL)shouldObserveProcessing;


#pragma mark - Handler methods

/**
 * Handling error which occurred while PubNub client
 * tried establish connection and lost internet connection
 */
- (void)handleConnectionErrorOnNetworkFailure;


#pragma mark - Misc methods

/**
 * This method will notify delegate about that
 * connection to the PubNub service is established
 * and send notification about it
 */
- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName;

/**
 * This method will notify delegate about that
 * subscription failed with error
 */
- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that
 * unsubscription failed with error
 */
- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that
 * time token retrieval failed because of error
 */
- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that
 * message sending failed because of error
 */
- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that
 * history loading error occurred
 */
- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that
 * participants list download error occurred
 */
- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error;

/**
 * This method allow to ensure that delegate can
 * process errors and will send error to the
 * delegate
 */
- (void)notifyDelegateAboutError:(PNError *)error;

- (void)sendNotification:(NSString *)notificationName withObject:(id)object;

/**
 * Retrieve request execution possibility code.
 * If everything is fine, than 0 will be returned, in
 * other case it will be treated as error and mean
 * that request execution is impossible
 */
- (NSInteger)requestExecutionPossibilityStatusCode;


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
    
    [self connectWithSuccessBlock:nil errorBlock:nil];
}

+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {
    
    BOOL shouldAddStateObservation = NO;
    
    // Check whether instance already connected or not
    if ([self sharedInstance].state == PNPubNubClientStateConnected ||
        [self sharedInstance].state == PNPubNubClientStateConnecting) {

        PNError *connectionError = [PNError errorWithCode:kPNClientTriedConnectWhileConnectedError];
        [[self sharedInstance] notifyDelegateAboutError:connectionError];
        
        if (failure) {

            failure(connectionError);
        }
    }
    else {
        
        // Check whether client configuration was provided
        // or not
        if ([self sharedInstance].configuration == nil) {

            PNError *connectionError = [PNError errorWithCode:kPNClientConfigurationError];
            [[self sharedInstance] notifyDelegateAboutError:connectionError];
            
            
            if(failure) {
                
                failure(connectionError);
            }
        }
        else {
            
            // Check whether user identifier was provided by
            // user or not
            if(![self sharedInstance].isUserProvidedClientIdentifier) {
                
                // Change user identifier before connect to the
                // PubNub services
                [self sharedInstance].clientIdentifier = PNUniqueIdentifier();
            }
            
            
            [self sharedInstance].connectOnServiceReachabilityCheck = NO;
            
            
            // Check whether services are available or not
            if ([[self sharedInstance].reachability isServiceReachabilityChecked]) {

                // Checking whether remote PubNub services is reachable or not
                // (if they are not reachable, this mean that probably there is no
                // connection)
                if ([[self sharedInstance].reachability isServiceAvailable]) {

                    // Notify PubNub delegate about that it will try to
                    // establish connection with remote PubNub origin
                    // (notify if delegate implements this method)
                    if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:willConnectToOrigin:)]) {
                        
                        [[self sharedInstance].delegate performSelector:@selector(pubnubClient:willConnectToOrigin:)
                                                             withObject:[self sharedInstance]
                                                             withObject:[self sharedInstance].configuration.origin];
                    }

                    [[self sharedInstance] sendNotification:kPNClientWillConnectToOriginNotification
                                                 withObject:[self sharedInstance].configuration.origin];


                    // Check whether PubNub client was just created and there
                    // is no resources for reuse or not
                    if ([self sharedInstance].state == PNPubNubClientStateCreated ||
                        [self sharedInstance].state == PNPubNubClientStateDisconnected) {

                        NSLog(@"{1} >>>>>>>>>>>>>>> CONNECTING STATE");
                        [self sharedInstance].state = PNPubNubClientStateConnecting;
                        
                        // Initialize communication channels
                        [self sharedInstance].messagingChannel = [PNMessagingChannel messageChannelWithDelegate:[self sharedInstance]];
                        [self sharedInstance].messagingChannel.messagingDelegate = [self sharedInstance];
                        [self sharedInstance].serviceChannel = [PNServiceChannel serviceChannelWithDelegate:[self sharedInstance]];
                        [self sharedInstance].serviceChannel.serviceDelegate = [self sharedInstance];
                    }
                    else {

                        NSLog(@"{2} >>>>>>>>>>>>>>> CONNECTING STATE");
                        [self sharedInstance].state = PNPubNubClientStateConnecting;
                        
                        
                        // Reuse existing communication channels and reconnect
                        // them to remote origin server
                        [[self sharedInstance].messagingChannel connect];
                        [[self sharedInstance].serviceChannel connect];
                    }
                    
                    shouldAddStateObservation = YES;
                }
                else {
                    
                    // Mark that client should try to connect when network will be available
                    // again
                    [self sharedInstance].connectOnServiceReachabilityCheck = YES;
                    
                    [[self sharedInstance] handleConnectionErrorOnNetworkFailure];
                    
                    
                    if(failure) {
                        
                        failure([PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]);
                    }
                }
            }
            // Looks like reachability manager was unable to check services reachability
            // (user still not configured client or just not enough time to check passed
            // since client configuration)
            else {
                
                [self sharedInstance].connectOnServiceReachabilityCheck = YES;
                
                shouldAddStateObservation = YES;
            }
        }
    }

    // Remove PubNub client from connection state observers list
    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self oneTimeEvent:YES];


    if(shouldAddStateObservation) {
        
        // Subscribe and wait for client connection state change notification
        [[self sharedInstance] setClientConnectionObservationWithSuccessBlock:success failureBlock:failure];
    }
}

+ (void)disconnect {
    
    // Remove PubNub client from list which help to observe various events
    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self oneTimeEvent:YES];
    if ([self sharedInstance].state != PNPubNubClientStateDisconnectingOnConfigurationChange) {

        [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
        [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
    }

    // Mark that client is disconnecting from remote PubNub services on
    // user request (or by internal client request when updating configuration)

    NSLog(@"{3} >>>>>>>>>>>>>>> DISCONNECTING STATE");
    [self sharedInstance].state = PNPubNubClientStateDisconnecting;


    // Empty connection pool after connection will
    // be closed
    [PNConnection closeAllConnections];
    
    
    // Destroy communication channels
    [self sharedInstance].messagingChannel = nil;
    [self sharedInstance].serviceChannel = nil;
}

+ (void)disconnectForConfigurationChange {

    // Mark that client is closing connection because of settings update

    NSLog(@"{4} >>>>>>>>>>>>>>> DISCONNECTING ON CONFIGURATION CHANGE STATE");
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
    // client configuration to it
    if ([configuration isValid]) {
        
        [self setDelegate:delegate];


        BOOL canUpdateConfiguration = YES;

        // Check whether PubNub client is connected to remote
        // PubNub services or not
        if ([[self sharedInstance] isConnected]) {

            // Check whether new configuration changed critical properties
            // of client configuration or not
            if([[self sharedInstance].configuration requiresConnectionResetWithConfiguration:configuration]) {

                canUpdateConfiguration = NO;

                // Store new configuration while client is disconnecting
                [self sharedInstance].temporaryConfiguration = configuration;


                // Disconnect before client configuration update
                [self disconnectForConfigurationChange];
            }
        }

        if (canUpdateConfiguration) {

            [self sharedInstance].configuration = configuration;
        }
        
        
        // Restart reachability monitor
        [[self sharedInstance].reachability startServiceReachabilityMonitoring];
    }
    else {
        
        // Notify delegate about client configuration error
        [[self sharedInstance] notifyDelegateAboutError:[PNError errorWithCode:kPNClientConfigurationError]];
    }
}

+ (void)setDelegate:(id<PNDelegate>)delegate {
    
    [self sharedInstance].delegate = delegate;
}


#pragma mark - Client identification methods

+ (void)setClientIdentifier:(NSString *)identifier {

    // Check whether identifier has been changed since last
    // method call or not
    if([[self sharedInstance] isConnected]) {
        
        // Checking whether new identifier was provided or not
        NSString *clientIdentifier = [self sharedInstance].clientIdentifier;
        if(![clientIdentifier isEqualToString:identifier]) {
            
            // Check whether user identifier was provided by
            // user or not
            if(![self sharedInstance].isUserProvidedClientIdentifier || clientIdentifier == nil) {
                
                [self sharedInstance].userProvidedClientIdentifier = NO;
                
                // Change user identifier before connect to the
                // PubNub services
                [self sharedInstance].clientIdentifier = PNUniqueIdentifier();
            }
            

            // We should resubscribe to the channels with new identifier
            // so correct presence will be called on them and notify
            // that user with old name leaved channel and joined with new
            // name
            [[self sharedInstance].messagingChannel resubscribe];
        }
    }
    else {
        
        [self sharedInstance].clientIdentifier = identifier;
        [self sharedInstance].userProvidedClientIdentifier = identifier != nil;
    }
}

+ (NSString *)clientIdentifier {
    
    NSString *identifier = [self sharedInstance].clientIdentifier;
    if (identifier == nil) {
        
        [self sharedInstance].userProvidedClientIdentifier = NO;
    }
    
    
    return [self sharedInstance].clientIdentifier;
}

+ (NSString *)escapedClientIdentifier {

    return [[self clientIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Channels subscription management

+ (NSArray *)subscribedChannels {

    return [[self sharedInstance].messagingChannel subscribedChannels];
}

+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel {

    BOOL isSubscribed = NO;

    // Ensure that PubNub client currently connected to
    // remote PubNub services
    if([[self sharedInstance] isConnected]) {

        isSubscribed = [[self sharedInstance].messagingChannel isSubscribedForChannel:channel];
    }


    return isSubscribed;
}

+ (void)subscribeOnChannel:(PNChannel *)channel {

    [self subscribeOnChannels:@[channel]];
}

+ (void) subscribeOnChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannels:@[channel] withPresenceEvent:withPresenceEvent];
}

+ (void)subscribeOnChannel:(PNChannel *)channel
         withPresenceEvent:(BOOL)withPresenceEvent
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:@[channel] withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels {

    [self subscribeOnChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:channels withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannels:channels withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels
          withPresenceEvent:(BOOL)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
    [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];


    // Check whether client is able to send request or not
    NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
    if (statusCode == 0) {

        if (handlerBlock != nil) {

            [[PNObservationCenter defaultCenter] addClientAsSubscriptionObserverWithBlock:handlerBlock];
        }


        [[self sharedInstance].messagingChannel subscribeOnChannels:channels withPresenceEvent:withPresenceEvent];
    }
    // Looks like client can't send request because of some reasons
    else {

        PNError *subscriptionError = [PNError errorWithCode:statusCode];
        subscriptionError.associatedObject = channels;

        [[self sharedInstance] notifyDelegateAboutSubscriptionFailWithError:subscriptionError];


        if(handlerBlock) {

            handlerBlock(channels, NO, subscriptionError);
        }
    }
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel {

    [self unsubscribeFromChannels:@[channel]];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannel:channel withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannel:channel withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
             withPresenceEvent:(BOOL)withPresenceEvent
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:@[channel]
                withPresenceEvent:withPresenceEvent
       andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels {

    [self unsubscribeFromChannels:channels withPresenceEvent:YES];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:channels withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
    [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];


    // Check whether client is able to send request or not
    NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
    if (statusCode == 0) {

        if (handlerBlock) {

            [[PNObservationCenter defaultCenter] addClientAsUnsubscribeObserverWithBlock:handlerBlock];
        }


        [[self sharedInstance].messagingChannel unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent];
    }
    // Looks like client can't send request because of some reasons
    else {

        PNError *unsubscriptionError = [PNError errorWithCode:statusCode];
        unsubscriptionError.associatedObject = channels;

        [[self sharedInstance] notifyDelegateAboutUnsubscriptionFailWithError:unsubscriptionError];


        if (handlerBlock) {

            handlerBlock(channels, unsubscriptionError);
        }
    }
}


#pragma mark - Presence management

+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {
    
    BOOL observingPresence = NO;

    // Ensure that PubNub client currently connected to
    // remote PubNub services
    if ([[self sharedInstance] isConnected]) {

        observingPresence = [[self sharedInstance].messagingChannel isPresenceObservationEnabledForChannel:channel];
    }
    
    
    return observingPresence;
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel {

    [self enablePresenceObservationForChannels:@[channel]];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels {

    [[self sharedInstance].messagingChannel enablePresenceObservationForChannels:channels];
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel {

    [self disablePresenceObservationForChannels:@[channel]];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels {

    [[self sharedInstance].messagingChannel disablePresenceObservationForChannels:channels];
}


#pragma mark - Time token

+ (void)requestServerTimeToken {

    [self requestServerTimeTokenWithCompletionBlock:nil];
}

+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {

    // Check whether client is able to send request or not
    NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
    if (statusCode == 0) {

        [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
        if (success) {
            [[PNObservationCenter defaultCenter] addClientAsTimeTokenReceivingObserverWithCallbackBlock:success];
        }


        [[self sharedInstance] sendRequest:[PNTimeTokenRequest new] shouldObserveProcessing:YES];
    }
    // Looks like client can't send request because of some reasons
    else {

        PNError *timeTokenError = [PNError errorWithCode:statusCode];

        [[self sharedInstance] notifyDelegateAboutTimeTokenRetrievalFailWithError:timeTokenError];


        if(success) {

            success(nil, timeTokenError);
        }
    }
}


#pragma mark - Messages processing methods

+ (PNMessage *)sendMessage:(NSString *)message toChannel:(PNChannel *)channel {

    return [self sendMessage:message toChannel:channel withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(NSString *)message
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {

    PNMessage *messageObject = nil;

    // Check whether client is able to send request or not
    NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
    if (statusCode == 0) {

        [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
        if (success) {

            [[PNObservationCenter defaultCenter] addClientAsMessageProcessingObserverWithBlock:success];
        }

        messageObject = [[self sharedInstance].serviceChannel sendMessage:message toChannel:channel];
    }
    // Looks like client can't send request because of some reasons
    else {

        PNError *sendingError = [PNError errorWithCode:statusCode];
        PNMessage *failedMessage = [PNMessage messageWithText:message forChannel:channel error:nil];
        sendingError.associatedObject = failedMessage;

        [[self sharedInstance] notifyDelegateAboutMessageSendingFailedWithError:sendingError];


        if (success) {

            success(PNMessageSendingError, sendingError);
        }
    }


    return messageObject;
}

+ (void)sendMessage:(PNMessage *)message {

    [self sendMessage:message withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success {

    [self sendMessage:message.message toChannel:message.channel withCompletionBlock:success];
}


#pragma mark - History methods

+ (void)requestFullHistoryForChannel:(PNChannel *)channel {

    [self requestFullHistoryForChannel:channel withCompletionBlock:nil];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:nil to:nil withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(NSDate *)startDate to:(NSDate *)endDate {

    [self requestHistoryForChannel:channel from:startDate to:endDate withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:startDate to:endDate limit:0 withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit {

    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel
                              from:startDate
                                to:endDate
                             limit:limit
                    reverseHistory:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {

    [self requestHistoryForChannel:channel
                              from:startDate
                                to:endDate
                             limit:limit
                    reverseHistory:shouldReverseMessageHistory
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    // Check whether client is able to send request or not
    NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
    if (statusCode == 0) {

        [[PNObservationCenter defaultCenter] removeClientAsHistoryDownloadObserver];
        if (handleBlock) {

            [[PNObservationCenter defaultCenter] addClientAsHistoryDownloadObserverWithBlock:handleBlock];
        }

        PNMessageHistoryRequest *request = [PNMessageHistoryRequest messageHistoryRequestForChannel:channel
                                                                                               from:startDate
                                                                                                 to:endDate
                                                                                              limit:limit
                                                                                     reverseHistory:shouldReverseMessageHistory];
        [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
    }
    // Looks like client can't send request because of some reasons
    else {

        PNError *sendingError = [PNError errorWithCode:statusCode];
        sendingError.associatedObject = channel;

        [[self sharedInstance] notifyDelegateAboutHistoryDownloadFailedWithError:sendingError];
    }
}


#pragma mark - Participant methods

+ (void)requestParticipantsListForChannel:(PNChannel *)channel {

    [self requestParticipantsListForChannel:channel withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    // Check whether client is able to send request or not
    NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
    if (statusCode == 0) {

        [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
        if (handleBlock) {

            [[PNObservationCenter defaultCenter] addClientAsParticipantsListDownloadObserverWithBlock:handleBlock];
        }


        PNHereNowRequest *request = [PNHereNowRequest whoNowRequestForChannel:channel];
        [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
    }
    // Looks like client can't send request because of some reasons
    else {

        PNError *sendingError = [PNError errorWithCode:statusCode];
        sendingError.associatedObject = channel;

        [[self sharedInstance] notifyDelegateAboutParticipantsListDownloadFailedWithError:sendingError];
    }
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {


        NSLog(@"{5} >>>>>>>>>>>>>>> CREATED STATE");
        self.state = PNPubNubClientStateCreated;
        self.launchSessionIdentifier = PNUniqueIdentifier();
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

                        BOOL shouldRestoreConnection = weakSelf.configuration.shouldAutoReconnectClient;
                        if ([weakSelf.delegate respondsToSelector:@selector(shouldReconnectPubNubClient:)]) {
                            
                            shouldRestoreConnection = [[weakSelf.delegate performSelector:@selector(shouldReconnectPubNubClient:)
                                                                               withObject:weakSelf] boolValue];
                        }
                        
                        
                        // Check whether should restore connection or not
                        if(shouldRestoreConnection) {

                            self.restoringConnection = YES;
                            
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


                            NSLog(@"{6} >>>>>>>>>>>>>>> DISCONNECTED ON ERROR STATE");
                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            
                            // Disconnect communication channels because of
                            // network issues
                            [weakSelf.messagingChannel disconnectWithReset:NO];
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

- (void)setClientConnectionObservationWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                                          failureBlock:(PNClientConnectionFailureBlock)failure {
    
    // Check whether at least one of blocks has been provided and whether
    // PubNub client already subscribed on state change event or not
    if(![[PNObservationCenter defaultCenter] isSubscribedOnClientStateChange:self] &&
       (success || failure)) {
    
        // Subscribing PubNub client for connection state observation
        // (as soon as event will occur PubNub client will be removed
        // from observers list)
        [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                                 oneTimeEvent:YES
                                                            withCallbackBlock:^(NSString *origin,
                                                                                BOOL connected,
                                                                                PNError *connectionError) {
                                                                
            // Notify subscriber via blocks
            if (connected && success) {
                
                success(origin);
            }
            else if (!connected && failure){
                
                failure(connectionError);
            }
        }];
    }
}

- (void)warmUpConnection {
    
    [self sendRequest:[PNTimeTokenRequest new] onChannel:self.messagingChannel shouldObserveProcessing:NO];
    [self sendRequest:[PNTimeTokenRequest new] onChannel:self.serviceChannel shouldObserveProcessing:NO];
}

- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    BOOL shouldSendOnMessageChannel = YES;
    
    
    // Checking whether request should be sent on service
    // connection channel or not
    if ([request isKindOfClass:[PNLeaveRequest class]] ||
        [request isKindOfClass:[PNTimeTokenRequest class]] ||
        [request isKindOfClass:[PNMessageHistoryRequest class]] ||
        [request isKindOfClass:[PNHereNowRequest class]] ||
        [request isKindOfClass:[PNLatencyMeasureRequest class]]) {
        
        shouldSendOnMessageChannel = NO;
    }
    
    
    [self sendRequest:request
            onChannel:(shouldSendOnMessageChannel?self.messagingChannel:self.serviceChannel)
      shouldObserveProcessing:shouldObserveProcessing];
}

- (void)sendRequest:(PNBaseRequest *)request
          onChannel:(PNConnectionChannel *)channel
    shouldObserveProcessing:(BOOL)shouldObserveProcessing; {
 
    [channel scheduleRequest:request shouldObserveProcessing:shouldObserveProcessing];
}


#pragma mark - Connection channel delegate methods

- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host {

    NSLog(@"MESSAGING CHANNEL CONNECTED? %@", [self.messagingChannel isConnected]?@"YES":@"NO");
    NSLog(@"SERVICE CHANNEL CONNECTED? %@", [self.serviceChannel isConnected]?@"YES":@"NO");
    NSLog(@"PubNub client state: %i (IS CONNECTING? %@)", self.state,
          self.state == PNPubNubClientStateConnecting?@"YES":@"NO");
    NSLog(@"IS SAME HOST? %@", [self.configuration.origin isEqualToString:host]?@"YES":@"NO");
    // Check whether all communication channels connected and whether
    // client in corresponding state or not
    if ([self.messagingChannel isConnected] && [self.serviceChannel isConnected] &&
        self.state == PNPubNubClientStateConnecting && [self.configuration.origin isEqualToString:host]) {
        
        // Mark that PubNub client established connection to PubNub
        // services

        NSLog(@"{7} >>>>>>>>>>>>>>> CONNECTED STATE");
        self.state = PNPubNubClientStateConnected;


        [self warmUpConnection];

        if (self.isRestoringConnection) {

            BOOL shouldResubscribe = self.configuration.shouldResubscribeOnConnectionRestore;
            if ([self.delegate respondsToSelector:@selector(shouldResubscribeOnConnectionRestore)]) {

                shouldResubscribe = [[self.delegate shouldResubscribeOnConnectionRestore] boolValue];
            }

            [self.messagingChannel restoreSubscription:shouldResubscribe];
        }

        self.restoringConnection = NO;

        [self notifyDelegateAboutConnectionToOrigin:host];
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
    
    
    // Check whether received event from same host on which client
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

                NSLog(@"{8} >>>>>>>>>>>>>>> DISCONNECTED ON NETWORK ERROR STATE");
            }
            else {

                NSLog(@"{9} >>>>>>>>>>>>>>> DISCONNECTED STATE");
            }
            self.state = state;
            
            SEL selectorForCheck = @selector(pubnubClient:didDisconnectFromOrigin:);
            if (state == PNPubNubClientStateDisconnectedOnNetworkError) {
                
                selectorForCheck = @selector(pubnubClient:didDisconnectFromOrigin:withError:);
            }
            if ([self.delegate respondsToSelector:selectorForCheck]) {
                
                if (self.state == PNPubNubClientStateDisconnected) {
                    
                    [self.delegate pubnubClient:self didDisconnectFromOrigin:host];

                    [self sendNotification:kPNClientDidDisconnectFromOriginNotification withObject:host];
                }
                else {

                    PNError *connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];

                    if ([self.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {

                        [self.delegate pubnubClient:self didDisconnectFromOrigin:host withError:connectionError];
                    }

                    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:connectionError];
                }
            }
            
            
            if(self.state == PNPubNubClientStateDisconnected) {
                
                // Clean up cached data
                [PNChannel purgeChannelsCache];
            }
        }
        // Check whether server unexpectedly closed connection
        // while client was active or not
        else if(self.state == PNPubNubClientStateConnected) {


            NSLog(@"{10} >>>>>>>>>>>>>>> DISCONNECTED STATE");
            self.state = PNPubNubClientStateDisconnected;
            
            
            // Check whether PubNub client should try to restore
            // connection with PubNub service
            BOOL shouldRestoreConnection = self.configuration.shouldAutoReconnectClient;
            if ([self.delegate respondsToSelector:@selector(shouldReconnectPubNubClient:)]) {
                
                shouldRestoreConnection = [[self.delegate performSelector:@selector(shouldReconnectPubNubClient:)
                                                               withObject:self] boolValue];
            }
            
            if(shouldRestoreConnection) {
                
                // Try to restore connection to remote PubNub services
                [[self class] connect];
            }
        }
        // Check whether connection has been closed because
        // PubNub client updates it's configuration
        else if (self.state == PNPubNubClientStateDisconnectingOnConfigurationChange) {
            
            // Close connection to PubNub services
            [[self class] disconnect];
            
            
            // Delay connection restore to give some time internal
            // components to complete their tasks
            int64_t delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {


                NSLog(@"{11} >>>>>>>>>>>>>>> CREATED STATE");
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
    
    if (self.state == PNPubNubClientStateConnected && [self.configuration.origin isEqualToString:host]) {


        NSLog(@"{12} >>>>>>>>>>>>>>> DISCONNECTING STATE");
        self.state = PNPubNubClientStateDisconnecting;
        BOOL disconnectedOnNetworkError = ![self.reachability isServiceAvailable];
        if(!disconnectedOnNetworkError) {

            disconnectedOnNetworkError = error.code == kPNRequestExecutionFailedOnInternetFailureError;
        }
        if (disconnectedOnNetworkError) {


            NSLog(@"{13} >>>>>>>>>>>>>>> DISCONNECTING ON NETWROK ERROR STATE");
            self.state = PNPubNubClientStateDisconnectingOnNetworkError;
        }
        
        
        if ([self.delegate respondsToSelector:@selector(pubnubClient:willDisconnectWithError:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:willDisconnectWithError:)
                                withObject:self
                                withObject:error];
        }

        [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
    }
}


#pragma mark - Handler methods

- (void)handleConnectionErrorOnNetworkFailure {
    
    PNError *networkError = [PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError];
    
    // Notify delegate about connection error if delegate
    // implemented error handling delegate method
    if ([self.delegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:connectionDidFailWithError:)
                            withObject:self
                            withObject:networkError];
    }

    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:networkError];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName {

    // Check whether delegate able to handle connection completion
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didConnectToOrigin:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didConnectToOrigin:)
                            withObject:self
                            withObject:self.configuration.origin];
    }

    [self sendNotification:kPNClientDidConnectToOriginNotification withObject:originHostName];
}

- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error {

    // Check whether delegate is able to handle subscription error
    // or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:subscriptionDidFailWithError:)]) {

        [self.delegate performSelector:@selector(pubnubClient:subscriptionDidFailWithError:)
                            withObject:self
                            withObject:(id)error];
    }

    [self sendNotification:kPNClientSubscriptionDidFailNotification withObject:error];

}

- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error {

    // Check whether delegate is able to handle unsubscription error
    // or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)]) {

        [self.delegate performSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)
                            withObject:self
                            withObject:(id)error];
    }

    [self sendNotification:kPNClientUnsubscriptionDidFailNotification withObject:error];
}

- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error {

    // Check whether delegate is able to handle time token retriaval
    // error or not
    if([self.delegate respondsToSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)]) {

        [self.delegate performSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)
                            withObject:self
                            withObject:error];
    }

    [self sendNotification:kPNClientDidFailTimeTokenReceiveNotification withObject:error];
}

- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error {

    // Check whether delegate is able to handle message sendinf error
    // or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailMessageSend:withError:)]) {

        [self.delegate pubnubClient:self didFailMessageSend:error.associatedObject withError:error];
    }

    [self sendNotification:kPNClientMessageSendingDidFailNotification withObject:error];
}

- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error {

    // Check whether delegate us able to handle message history download error
    // or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailHistoryDownloadForChannel:withError:)]) {

        [self.delegate pubnubClient:self
   didFailHistoryDownloadForChannel:error.associatedObject
                          withError:error];
    }

    [self sendNotification:kPNClientHistoryDownloadFailedWithErrorNotification withObject:error];
}

- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error {

    // Check whether delegate us able to handle participants list
    // download error or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailParticipantsListDownloadForChannel:withError:)]) {

        [self.delegate       pubnubClient:self
didFailParticipantsListDownloadForChannel:error.associatedObject
                                withError:error];
    }

    [self sendNotification:kPNClientParticipantsListDownloadFailedWithErrorNotification withObject:error];
}

- (void)notifyDelegateAboutError:(PNError *)error {
        
    if ([self.delegate respondsToSelector:@selector(pubnubClient:error:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:error:)
                            withObject:self
                            withObject:error];
    }

    [self sendNotification:kPNClientErrorNotification withObject:error];
}

- (void)sendNotification:(NSString *)notificationName withObject:(id)object {

    // Send notification to all who is interested in it
    // (observation center will track it as well)
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:object];
}

- (NSInteger)requestExecutionPossibilityStatusCode {

    NSInteger statusCode = 0;

    // Check whether client can subscribe for channels or not
    if ([self.reachability isServiceReachabilityChecked] && [self.reachability isServiceAvailable]) {

        if (![self isConnected]) {

            statusCode = kPNRequestExecutionFailedClientNotReadyError;
        }
    }
    else {

        statusCode = kPNRequestExecutionFailedOnInternetFailureError;
    }


    return statusCode;
}


#pragma mark - Message channel delegate methods

- (void)messagingChannel:(PNMessagingChannel *)channel didSubscribeOnChannels:(NSArray *)channels {

    // Check whether delegate can handle subscription on channel or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didSubscribeOnChannels:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didSubscribeOnChannels:)
                            withObject:self
                            withObject:channels];
    }


    [self sendNotification:kPNClientSubscriptionDidCompleteNotification withObject:channels];
}

- (void)  messagingChannel:(PNMessagingChannel *)channel
didFailSubscribeOnChannels:(NSArray *)channels
                 withError:(PNError *)error {

    error.associatedObject = channels;
    [self notifyDelegateAboutSubscriptionFailWithError:error];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didUnsubscribeFromChannels:(NSArray *)channels {

    // Check whether delegate can handle unsubscription event or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)
                            withObject:self
                            withObject:channels];
    }

    [self sendNotification:kPNClientUnsubscriptionDidCompleteNotification withObject:channels];
}

- (void)    messagingChannel:(PNMessagingChannel *)channel
didFailUnsubscribeOnChannels:(NSArray *)channels
                   withError:(PNError *)error {

    error.associatedObject = channels;
    [self notifyDelegateAboutUnsubscriptionFailWithError:error];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveMessage:(PNMessage *)message {

    // Check whether delegate can handle new message arrival or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didReceiveMessage:)
                            withObject:self
                            withObject:message];
    }

    [self sendNotification:kPNClientDidReceiveMessageNotification withObject:message];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event {

    // Try to update cached channel data
    PNChannel *channel = event.channel;
    if (channel) {

        [channel updateWithEvent:event];
    }

    // Check whether delegate can handle presence event arrival or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceivePresenceEvent:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didReceivePresenceEvent:)
                            withObject:self
                            withObject:event];
    }

    [self sendNotification:kPNClientDidReceivePresenceEventNotification withObject:event];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken {

    // Check whether delegate can handle time token retrieval or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveTimeToken:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didReceiveTimeToken:)
                            withObject:self
                            withObject:timeToken];
    }


    [self sendNotification:kPNClientDidReceiveTimeTokenNotification withObject:timeToken];
}

- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error {

    [self notifyDelegateAboutTimeTokenRetrievalFailWithError:error];
}

- (void)  serviceChannel:(PNServiceChannel *)channel
didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth {

    // TODO: NOTIFY NETWORK METER INSTANCE ABOUT ARRIVED DATA
}

- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message {

    // Check whether delegate can handle message sending event or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:willSendMessage:)]) {

        [self.delegate performSelector:@selector(pubnubClient:willSendMessage:)
                            withObject:self
                            withObject:message];
    }

    [self sendNotification:kPNClientWillSendMessageNotification withObject:message];
}

- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message {

    // Check whether delegate can handle message sent event or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {

        [self.delegate performSelector:@selector(pubnubClient:didSendMessage:)
                            withObject:self
                            withObject:message];
    }

    [self sendNotification:kPNClientDidSendMessageNotification withObject:message];
}

- (void)serviceChannel:(PNServiceChannel *)channel
    didFailMessageSend:(PNMessage *)message
             withError:(PNError *)error {

    error.associatedObject = message;
    [self notifyDelegateAboutMessageSendingFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history {

    // Check whether delegate can response on history download event or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessageHistory:forChannel:startingFrom:to:)]) {

        [self.delegate pubnubClient:self
           didReceiveMessageHistory:history.messages
                         forChannel:history.channel
                       startingFrom:history.startDate
                                 to:history.endDate];
    }

    [self sendNotification:kPNClientDidReceiveMessagesHistoryNotification withObject:history];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel
        didFailHisoryDownloadForChannel:(PNChannel *)channel
        withError:(PNError*)error {

    error.associatedObject = channel;
    [self notifyDelegateAboutHistoryDownloadFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants {

    // Check whether delegate can response on participants list download event or not
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantsLits:forChannel:)]) {

        [self.delegate pubnubClient:self
         didReceiveParticipantsLits:participants.participants
                         forChannel:participants.channel];
    }

    [self sendNotification:kPNClientDidReceiveParticipantsListNotification withObject:participants];
}

- (void)               serviceChannel:(PNServiceChannel *)serviceChannel
didFailParticipantsListLoadForChannel:(PNChannel *)channel
                            withError:(PNError *)error {

    error.associatedObject = channel;
    [self notifyDelegateAboutParticipantsListDownloadFailedWithError:error];

}

#pragma mark -


@end
