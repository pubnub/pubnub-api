//
//  PubNub.h
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

#import <Foundation/Foundation.h>
#import "PNDelegate.h"


#pragma mark Class forward

@class PNConfiguration;


@interface PubNub : NSObject


#pragma mark Class methods

/**
 * Retrieve reference on shared PubNub client instance
 */
+ (PubNub *)sharedInstance;


#pragma mark - Client connection management methods

/**
 * Launch configured PubNub client (this will cause initial
 * connection which will retrieve time token from backend 
 * and open two connections/sockets which will be used for 
 * communication with PubNub services).
 */
+ (void)connect;

/**
 * Will disconnect from all channels w/o sending leave
 * event and terminate all socket connection which was
 * established to PubNub services.
 * All scheduled messages will be discarded.
 */
+ (void)disconnect;


#pragma mark - Client configuration

/**
 * Perform initial configuration or update existing one
 * If PubNub was previously configured, it will perform
 * "hard reset".
 * "hard reset" - is action when all connection will be 
 *                dropped w/o notify to the server.
 *                All scheduled messages will be discarded 
 *                (try to avoid runtime re-configuration 
 *                of the client)
 */
+ (void)setConfiguration:(PNConfiguration *)configuration;
+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;

/**
 * Specify PubNub client delegate for event callbacks
 */
+ (void)setDelegate:(id<PNDelegate>)delegate;


#pragma mark - Client identification

/**
 * Update current PubNub client identifier (unique user identifier
 * or basically username/nickname)
 * If PubNub was previously configured, it will perform
 * "soft reset".
 * If 'nil' is passed, than random unique identifier will
 * be generated.
 * "soft reset" - is action when before connection drop 
 *                client will send "leave" messages to
 *                the server which will allow to process
 *                presence correctly.
 */
+ (void)setClientIdentifier:(NSString *)identifier;

/**
 * Retrieve current PubNub client identifier which will/used to
 * establish connection with PubNub services
 */
+ (NSString *)clientIdentifier;


#pragma mark - Instance methods

/**
 * Check whether PubNub client connected to origin
 * and ready to work or not
 */
- (BOOL)isConnected;

/**
 * Send asynchronous time token request to PubNub
 * services.
 * Response will retrieve all who subscribed for
 * time token retrival via observer center or
 * notifications
 */
- (void)requestServerTimeToken;


#pragma mark -


@end
