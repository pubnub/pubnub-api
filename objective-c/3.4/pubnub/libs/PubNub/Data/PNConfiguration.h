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
@property (nonatomic, copy) NSString *host;

// Stores reference on keys which is required
// to establish connection and send packets to it
@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *cipherKey;

// Stores whether connection should be established
// with SSL support or not
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL useSecureConnection;



#pragma mark - Class methods

/**
 * Retrieve reference on default configuration
 * which is initiated with values from 
 * PNDefaultConfiguration.h header file
 */
+ (PNConfiguration *)defaultConfiguration;

/**
 * Retrieve reference on configuration with full
 * set of options specified by user
 */
+ (PNConfiguration *)configurationForHost:(NSString *)originHostName
                               publishKey:(NSString *)publishKey
                             subscribeKey:(NSString *)subscribeKey
                                secretKey:(NSString *)secretKey
                                cipherKey:(NSString *)cipherKey
                      useSecureConnection:(BOOL)shouldUseSecureConnection;


#pragma mark - Instance methods

/**
 * Initialize configuration instance with specified
 * set of parameters
 */
- (id)initWithHost:(NSString *)originHostName
        publishKey:(NSString *)publishKey
      subscribeKey:(NSString *)subscribeKey
         secretKey:(NSString *)secretKey
         cipherKey:(NSString *)cipherKey
   useSecureConnection:(BOOL)shouldUseSecureConnection;

/**
 * Check whether configuration is valid or not
 */
- (BOOL)isValid;

#pragma mark -


@end
