//
//  PNDataManager.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNDataManager.h"


#pragma mark Static

// Stores reference on shared data manager instance
static PNDataManager *_sharedInstance = nil;


#pragma mark - Private interface methods

@interface PNDataManager ()


#pragma mark - Properties

@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on list of channels on which client is subscribed
@property (nonatomic, strong) NSArray *subscribedChannelsList;


@end


#pragma mark - Public interface methods

@implementation PNDataManager


#pragma mark - Class methods

+ (PNDataManager *)sharedInstance {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [PNDataManager new];
    });


    return _sharedInstance;
}


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization successful or not
    if((self = [super init])) {

        self.configuration = [PNConfiguration defaultConfiguration];
        self.subscribedChannelsList = [NSMutableArray array];

        [[PNObservationCenter defaultCenter] addClientChannelSubscriptionObserver:self
                                                                withCallbackBlock:^(NSArray *channels,
                                                                                    BOOL subscribed,
                                                                                    PNError *subscriptionError) {

                    if (subscribed) {

                        NSArray *unsortedList = [PubNub subscribedChannels];
                        NSSortDescriptor *nameSorting = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                        self.subscribedChannelsList = [unsortedList sortedArrayUsingDescriptors:@[nameSorting]];
                    }
                }];
    }


    return self;
}

- (void)updateSSLOption:(BOOL)shouldEnableSSL {

    // This is very hard construction for configuration creation, better
    // use PNDefaultConfiguration.h header file and [PNConfiguration defaultConfiguration]
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:self.configuration.origin
                                                                  publishKey:self.configuration.publishKey
                                                                subscribeKey:self.configuration.subscriptionKey
                                                                   secretKey:self.configuration.secretKey
                                                                   cipherKey:self.configuration.cipherKey
                                                         useSecureConnection:shouldEnableSSL
                                                         shouldAutoReconnect:self.configuration.shouldAutoReconnectClient
                                            shouldReduceSecurityLevelOnError:self.configuration.shouldReduceSecurityLevelOnError
                                        canIgnoreSecureConnectionRequirement:self.configuration.canIgnoreSecureConnectionRequirement];

    self.configuration = configuration;
}


#pragma mark -

@end