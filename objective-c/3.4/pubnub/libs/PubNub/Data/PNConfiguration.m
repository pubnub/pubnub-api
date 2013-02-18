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

#import "PNDefaultConfiguration.h"
#import "PNConstants.h"


#pragma mark Private interface methods

@interface PNConfiguration ()


#pragma mark - Properties

// Stores reference on services host name
@property (nonatomic, copy) NSString *origin;

// Stores reference on original origin host address
// (this property is used when DNS killer is required)
@property (nonatomic, copy) NSString *realOrigin;

// Stores reference on keys which is required
// to establish connection and send packets to it
@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *cipherKey;


@end


#pragma mark - Public interface methods

@implementation PNConfiguration


#pragma mark - Class methods

+ (PNConfiguration *)defaultConfiguration {
    
    return [self configurationForOrigin:kPNOriginHost
                             publishKey:kPNPublishKey
                           subscribeKey:kPNSubscriptionKey
                              secretKey:kPNSecretKey
                              cipherKey:kPNCipherKey];
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
                              cipherKey:kPNCipherKey];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey {
    
    return [[[self class] alloc] initWithOrigin:originHostName
                                     publishKey:publishKey
                                   subscribeKey:subscribeKey
                                      secretKey:secretKey
                                      cipherKey:cipherKey];
}


#pragma mark - Instance methods


- (id)initWithOrigin:(NSString *)originHostName
          publishKey:(NSString *)publishKey
        subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey
           cipherKey:(NSString *)cipherKey {
    
    // Checking whether initialization was successful or not
    if((self = [super init])) {
        
        self.origin = ([originHostName length] > 0)?originHostName:kPNDefaultOriginHost;
        self.realOrigin = self.origin;
        self.publishKey = publishKey?publishKey:@"";
        self.subscriptionKey = subscribeKey?subscribeKey:@"";
        self.secretKey = secretKey?secretKey:@"0";
        self.cipherKey = cipherKey?cipherKey:@"";
        self.useSecureConnection = kPNSecureConnectionRequired;
        self.autoReconnectClient = kPNShouldAutoReconnectClient;
        self.reduceSecurityLevelOnError = kPNShouldReduceSecurityLevelOnError;
        self.ignoreSecureConnectionRequirement = kPNCanIgnoreSecureConnectionRequirement;
        self.resubscribeOnConnectionRestore = kPNShouldResubscribeOnConnectionRestore;
        self.nonSubscriptionRequestTimeout = kPNNonSubscriptionRequestTimeout;
        self.subscriptionRequestTimeout = kPNSubscriptionRequestTimeout;

        // Checking whether user changed origin host from default
        // or not
        if ([self.origin isEqualToString:kPNDefaultOriginHost]) {
            PNLog(PNLogGeneralLevel, self, @"\n{WARN} Before running in production, please contact support@pubnub.com for your custom origin.\nPlease set the origin from %@ to IUNDERSTAND.pubnub.com to remove this warning.", self.origin);
        }
    }
    
    
    return self;
}

- (BOOL)requiresConnectionResetWithConfiguration:(PNConfiguration *)configuration {

    BOOL shouldReset = NO;


    if (configuration != nil) {

        // Checking whether critical configuration information has been changed or not
        if ((self.shouldUseSecureConnection != configuration.shouldUseSecureConnection) ||
            ![self.origin isEqualToString:configuration.origin]) {

            shouldReset = YES;
        }
    }

    return shouldReset;
}

- (void)shouldKillDNSCache:(BOOL)shouldKillDNSCache {

    if (shouldKillDNSCache) {

        NSString *subDomain = [self.realOrigin stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",
                                                                                     kPNServiceMainDomain]
                                                                         withString:@""];

        self.origin = [NSString stringWithFormat:@"%@-%d.%@", subDomain, PNRandomInteger(), kPNServiceMainDomain];
    }
    else {

        self.origin = self.realOrigin;
    }
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
