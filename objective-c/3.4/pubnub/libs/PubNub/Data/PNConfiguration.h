//
//  PNConfiguration.h
//  pubnub
//
//  This class allow to configure PubNub
//  base class with required set of parameters.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import <Foundation/Foundation.h>


@interface PNConfiguration : NSObject


#pragma mark Properties

// Stores reference on services host name
@property (nonatomic, readonly, copy) NSString *origin;

// Stores reference on keys which is required
// to establish connection and send packets to it
@property (nonatomic, readonly, copy) NSString *publishKey;
@property (nonatomic, readonly, copy) NSString *subscriptionKey;
@property (nonatomic, readonly, copy) NSString *secretKey;
@property (nonatomic, readonly, copy) NSString *cipherKey;

// Stores timeout which is used for non-subscription
// requests to report that request failed
@property (nonatomic, assign) NSTimeInterval nonSubscriptionRequestTimeout;

// Stores timeout which is used for subscription
// requests to report that request failed
@property (nonatomic, assign) NSTimeInterval subscriptionRequestTimeout;

// Stores whether client should restore subscription
// on channels from same point where connection
// has been lost or resubscribe on them
// Set YES if you want to discard all events which occurred
// while connection  went down
@property (nonatomic, assign, getter = shouldResubscribeOnConnectionRestore) BOOL resubscribeOnConnectionRestore;

// Stores whether client can ignore security
// requirements and connection using plain HTTP
// connection in case of SSL error
@property (nonatomic, assign, getter = canIgnoreSecureConnectionRequirement) BOOL ignoreSecureConnectionRequirement;

// Stores whether SSL security rules should be
// lowered when connection error occurs or not
@property (nonatomic, assign, getter = shouldReduceSecurityLevelOnError) BOOL reduceSecurityLevelOnError;

// Stores whether connection should be established
// with SSL support or not
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL useSecureConnection;

// Stores whether connection should be restored
// if it failed in previuos sesion or not
@property (nonatomic, assign, getter = shouldAutoReconnectClient) BOOL autoReconnectClient;


#pragma mark - Class methods

/**
 * Retrieve reference on default configuration
 * which is initiated with values from 
 * PNDefaultConfiguration.h header file
 */
+ (PNConfiguration *)defaultConfiguration;

/**
 * Retrieve reference on lightweight configuration which
 * require only few parameters from user
 */
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey
                                    subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey 
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey;

/**
 * Retrieve reference on configuration with full
 * set of options specified by user
 */
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey;


#pragma mark - Instance methods

/**
 * Initialize configuration instance with specified
 * set of parameters
 */
- (id)initWithOrigin:(NSString *)originHostName
          publishKey:(NSString *)publishKey
        subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey
           cipherKey:(NSString *)cipherKey;

/**
 * Check whether PubNub client should reset connection
 * because new configuration instance changed critical
 * parts of configuration or not
 */
- (BOOL)requiresConnectionResetWithConfiguration:(PNConfiguration *)configuration;

/**
 * Check whether configuration is valid or not
 */
- (BOOL)isValid;

#pragma mark -


@end
