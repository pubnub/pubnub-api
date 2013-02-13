//
//  PubNub+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNConfiguration.h"
#import "PNReachability.h"
#import "PNDelegate.h"
#import "PubNub.h"


#pragma mark Static

typedef enum _PNPubNubClientState {
    
    // Client instance was just created
    PNPubNubClientStateCreated,
    
    // Client is trying to establish connection
    // to remote PubNub services
    PNPubNubClientStateConnecting,
    
    // Client successfully connected to
    // remote PubNub services
    PNPubNubClientStateConnected,
    
    // Client is disconnecting from remote
    // services
    PNPubNubClientStateDisconnecting,
    
    // Client closing connection because configuration
    // has been changed while client was connected
    PNPubNubClientStateDisconnectingOnConfigurationChange,
    
    // Client is disconnecting from remote
    // services because of network failure
    PNPubNubClientStateDisconnectingOnNetworkError,
    
    // Client disconnected from remote PubNub
    // services (by user request)
    PNPubNubClientStateDisconnected,
    
    // Cliend disconnected from remote PubNub
    // service because of network failure
    PNPubNubClientStateDisconnectedOnNetworkError
} PNPubNubClientState;


@interface PubNub (Protected)


#pragma mark - Properties

// Stores reference on configuration which was used to
// perform initial PubNub client initialization
@property (nonatomic, copy) PNConfiguration *configuration;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;

// Stores unique client initialization session identifier
// (created each time when PubNub stack is configured
// after application launch)
@property (nonatomic, strong) NSString *launchSessionIdentifier;


#pragma mark - Class methods

/**
 * Return reference on client identifier which is ready
 * to be sent as part of GET HTTP request (encoded with %
 * which allow to use it to send in HTTP requests)
 */
+ (NSString *)escapedClientIdentifier;


#pragma mark - Instance methods

/**
 * Return reference on reachability instance which is used to
 * track network state
 */
- (PNReachability *)reachability;

#pragma mark -


@end