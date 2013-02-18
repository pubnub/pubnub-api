//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNIdentificationViewController.h"
#import "PNPresenceEvent.h"
#import "PNMessage.h"


#pragma mark Private interface methods

@interface PNAppDelegate ()


#pragma mark - Properties

// Stores whether client disconnected on network error
// or not
@property (nonatomic, assign, getter = isDisconnectedOnNetworkError) BOOL disconnectedOnNetworkError;


#pragma mark - Instance methods

- (void)initializePubNubClient;


@end


#pragma mark - Public interface methods

@implementation PNAppDelegate


#pragma mark - Instance methods

- (void)initializePubNubClient {

    [PubNub setDelegate:self];


    // Subscribe for client connection state change
    // (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {

                if (!connected && error) {

                    PNLog(PNLogGeneralLevel, self, @"#2 PubNub client was unable to connect because of error: %@",
                          [error localizedDescription],
                          [error localizedFailureReason]);
                }
            }];


    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                     NSArray *channels,
                                                                                     PNError *subscriptionError) {

                                            switch (state) {

                                                case PNSubscriptionProcessNotSubscribedState:

                                                    PNLog(PNLogGeneralLevel, self,
                                                          @"{BLOCK-P} PubNub client subscription failed with error: %@",
                                                          subscriptionError);
                                                    break;

                                                case PNSubscriptionProcessSubscribedState:

                                                    PNLog(PNLogGeneralLevel, self,
                                                          @"{BLOCK-P} PubNub client subscribed on channels: %@",
                                                          channels);
                                                    break;

                                                case PNSubscriptionProcessWillRestoreState:

                                                    PNLog(PNLogGeneralLevel, self,
                                                          @"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
                                                          channels);
                                                    break;

                                                case PNSubscriptionProcessRestoredState:

                                                    PNLog(PNLogGeneralLevel, self,
                                                          @"{BLOCK-P} PubNub client restores subscribed on channels: %@",
                                                          channels);
                                                    break;
                                            }
                                        }];

    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                     PNLog(PNLogGeneralLevel, self, @"{BLOCK-P} PubNubc client received new message: %@",
                                           message);
                            }];

    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self
                                                         withBlock:^(PNPresenceEvent *presenceEvent) {

                                     PNLog(PNLogGeneralLevel, self, @"{BLOCK-P} PubNubc client received new event: %@",
                                           presenceEvent);
                            }];

}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PNIdentificationViewController new];
    [self.window makeKeyAndVisible];
    
    [self initializePubNubClient];
    
    
    return YES;
}


#pragma mark - PubNub client delegate methods

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {


    if (self.isDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"PubNub client trying to restore connection to PubNub origin at: %@", origin);
    }
    else {

        PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {

    if (self.isDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"PubNub client restored connection to PubNub origin at: %@", origin);
    }
    else {

        PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
    }


    self.disconnectedOnNetworkError = NO;
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"#1 PubNub client was unable to connect because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionFailedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionClosedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {

    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}

- (void)pubnubClient:(PubNub *)client
        didReceiveMessageHistory:(NSArray *)messages
        forChannel:(PNChannel *)channel
        startingFrom:(NSDate *)startDate
        to:(NSDate *)endDate {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@",
          channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@",
          channel, error);
}

- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsLits:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@",
          participantsList, channel);
}

- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {

    NSNumber *shouldResubscribeOnConnectionRestore = @(NO);

    if ([[PubNub subscribedChannels] count] > 0) {

        NSString *lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];

        if ([shouldResubscribeOnConnectionRestore boolValue]) {

            lastTimeToken = @"0";
        }

        PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription? %@. Resuming at last time token: %@",
              ![shouldResubscribeOnConnectionRestore boolValue]?@"YES":@"NO",
              lastTimeToken);
    }


    return shouldResubscribeOnConnectionRestore;
}

#pragma mark -


@end
