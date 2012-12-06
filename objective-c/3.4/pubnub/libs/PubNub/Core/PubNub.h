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


#pragma mark - Class methods


#pragma mark - Client connection management methods

/**
 * Launch configured PubNub client (this will cause initial
 * connection which will retrieve time token from backend 
 * and open two connections/sockets which will be used for 
 * communication with PubNub services).
 * 
 */
+ (void)connect;


#pragma mark - Client configuration

/**
 * Perform initial configuration or update existing one
 * If PubNub was previously configured, it will perform
 * "hard reset".
 * "hard reset" - is action when all connection will be 
 *                dropped w/o notify to the server (try
 *                to avoid runtime re-configuration of the
 *                client)
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


#pragma mark -


@end
