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
@property (nonatomic, copy) NSString *origin;

// Stores reference on keys which is required
// to establish connection and send packets to it
@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *cipherKey;

// Stores whether connection should be established
// with SSL support or not
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL useSecureConnection;

// Stores whether connection should be restored
// if it failed in previuos sesion or not
@property (nonatomic, assign, getter = shouldAutoReconnectClient) BOOL autoReconnectClient;

// Stores whether SSL security rules should be
// lowered when connection error occures or not
@property (nonatomic, assign, getter = shouldReduceSecurityLevelOnError) BOOL reduceSecurityLevelOnError;

// Stores whether client can ignore security
// requirements and connection using plain HTTP
// connection in case of SSL error
@property (nonatomic, assign, getter = canIgnoreSecureConnectionRequirement) BOOL ignoreSecureConnectionRequirement;


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
                                  cipherKey:(NSString *)cipherKey
                        useSecureConnection:(BOOL)shouldUseSecureConnection
                        shouldAutoReconnect:(BOOL)shouldAutoReconnect
           shouldReduceSecurityLevelOnError:(BOOL)shouldReduceSecurityLevelOnError
       canIgnoreSecureConnectionRequirement:(BOOL)canIgnoreSecureConnectionRequirement;


#pragma mark - Instance methods

/**
 * Initialize configuration instance with specified
 * set of parameters
 */
- (id)initWithOrigin:(NSString *)originHostName
          publishKey:(NSString *)publishKey
        subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey
           cipherKey:(NSString *)cipherKey
 useSecureConnection:(BOOL)shouldUseSecureConnection
 shouldAutoReconnect:(BOOL)shouldAutoReconnect
shouldReduceSecurityLevelOnError:(BOOL)shouldReduceSecurityLevelOnError
canIgnoreSecureConnectionRequirement:(BOOL)canIgnoreSecureConnectionRequirement;

/**
 * Check whether configuration is valid or not
 */
- (BOOL)isValid;

#pragma mark -


@end
