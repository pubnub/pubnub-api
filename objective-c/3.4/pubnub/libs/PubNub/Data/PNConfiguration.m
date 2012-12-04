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
#import "PNContants.h"


#pragma mark Public interface methods

@implementation PNConfiguration


#pragma mark - Class methods

+ (PNConfiguration *)defaultConfiguration {
    
    return [self configurationForHost:kPNHost
                           publishKey:kPNPublishKey
                         subscribeKey:kPNSubscriptionKey
                            secretKey:kPNSecretKey
                            cipherKey:kPNCipherKey
                  useSecureConnection:kPNSecureConnectionRequired];
}

+ (PNConfiguration *)configurationForHost:(NSString *)originHostName
                               publishKey:(NSString *)publishKey
                             subscribeKey:(NSString *)subscribeKey
                                secretKey:(NSString *)secretKey
                                cipherKey:(NSString *)cipherKey
                      useSecureConnection:(BOOL)shouldUseSecureConnection {
    
    return [[[self class] alloc] initWithHost:originHostName
                                   publishKey:publishKey
                                 subscribeKey:subscribeKey
                                    secretKey:secretKey
                                    cipherKey:cipherKey
                          useSecureConnection:shouldUseSecureConnection];
}


#pragma mark - Instance methods


- (id)initWithHost:(NSString *)originHostName
        publishKey:(NSString *)publishKey
      subscribeKey:(NSString *)subscribeKey
         secretKey:(NSString *)secretKey
         cipherKey:(NSString *)cipherKey
   useSecureConnection:(BOOL)shouldUseSecureConnection {
    
    // Checking whether initialization was successful or not
    if((self = [super init])) {
        
        self.host = ([originHostName length] > 0)?originHostName:kPNDefaultHost;
        self.publishKey = publishKey;
        self.subscriptionKey = subscribeKey;
        self.secretKey = secretKey;
        self.cipherKey = cipherKey;
        self.useSecureConnection = shouldUseSecureConnection;
        
        
#ifndef DEBUG
        if (self.host isEqualToString:kPNDefaultHost) {
#warning Please change services host URL for production version
        }
#endif
    }
    
    
    return self;
}

- (BOOL)isValid {
    
    BOOL isValid = YES;
    
    
    // Check whether publish key was specified or not
    isValid = isValid?([self.publishKey length] > 0):isValid;
    
    
    return isValid;
}

@end
