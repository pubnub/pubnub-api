//
//  PNConfiguration.m
//  pubnub
//
//  This class allow to configure PubNub
//  base class with required set of parameters.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNConfiguration.h"
#import "PNDefaultConfiguration.h"
#import "PNConstants.h"
#import "PNMacro.h"


#pragma mark Public interface methods

@implementation PNConfiguration


#pragma mark - Class methods

+ (PNConfiguration *)defaultConfiguration {
    
    return [self configurationForOrigin:kPNOriginHost
                             publishKey:kPNPublishKey
                           subscribeKey:kPNSubscriptionKey
                              secretKey:kPNSecretKey
                              cipherKey:kPNCipherKey
                    useSecureConnection:kPNSecureConnectionRequired
                    shouldAutoReconnect:kPNShouldAutoReconnectClient];
}

+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey
                                    subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey {
    
    return [self configurationForOrigin:kPNDefaultOriginHost
                             publishKey:publishKey
                           subscribeKey:subscribeKey
                              secretKey:secretKey];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey {
    
    return [self configurationForOrigin:originHostName
                             publishKey:publishKey
                           subscribeKey:subscribeKey
                              secretKey:secretKey
                              cipherKey:nil
                    useSecureConnection:kPNSecureConnectionByDefault
                    shouldAutoReconnect:kPNShouldAutoReconnectClientByDefault];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey
                        useSecureConnection:(BOOL)shouldUseSecureConnection
                        shouldAutoReconnect:(BOOL)shouldAutoReconnectClient {
    
    return [[[self class] alloc] initWithOrigin:originHostName
                                     publishKey:publishKey
                                   subscribeKey:subscribeKey
                                      secretKey:secretKey
                                      cipherKey:cipherKey
                            useSecureConnection:shouldUseSecureConnection
                            shouldAutoReconnect:shouldAutoReconnectClient];
}


#pragma mark - Instance methods


- (id)initWithOrigin:(NSString *)originHostName
          publishKey:(NSString *)publishKey
        subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey
           cipherKey:(NSString *)cipherKey
 useSecureConnection:(BOOL)shouldUseSecureConnection
 shouldAutoReconnect:(BOOL)shouldAutoReconnectClient {
    
    // Checking whether initialization was successful or not
    if((self = [super init])) {
        
        self.origin = ([originHostName length] > 0)?originHostName:kPNDefaultOriginHost;
        self.publishKey = publishKey?publishKey:@"";
        self.subscriptionKey = subscribeKey?subscribeKey:@"";
        self.secretKey = secretKey?secretKey:@"0";
        self.cipherKey = cipherKey?cipherKey:@"";
        self.useSecureConnection = shouldUseSecureConnection;
        self.autoReconnectClient = shouldAutoReconnectClient;
     
        // Checking whether user changed origin host from default
        // or not
        if ([self.origin isEqualToString:kPNDefaultOriginHost]) {
            PNLog(@"\n{WARN} Before running in production, please contact support@pubnub.com for your custom origin.\nPlease set the origin from %@ to IUNDERSTAND.pubnub.com to remove this warning.", self.origin);
        }
    }
    
    
    return self;
}

- (BOOL)isValid {
    
    BOOL isValid = YES;
    
    
    // Check whether publish/subscription/secret keys are valid or not
    isValid = isValid?([self.publishKey length] > 0):isValid;
    isValid = isValid?([self.subscriptionKey length] > 0):isValid;
    isValid = isValid?([self.secretKey length] > 0):isValid;
    
    
    return isValid;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"\nConfiguration for: %@ (secured: %@)\nPublish key (Required): %@\nSubscription key (Required): %@\nSecret key (Required): %@\nCipher key: %@",
            self.origin,
            self.shouldUseSecureConnection?@"YES":@"NO",
            ([self.publishKey length] > 0)?self.publishKey:@"-missing-",
            ([self.subscriptionKey length] > 0)?self.subscriptionKey:@"-missing-",
            ([self.secretKey length] > 0)?self.secretKey:@"missing",
            ([self.cipherKey length] > 0)?self.cipherKey:@"-no encription key-"];
}

#pragma mark -


@end
