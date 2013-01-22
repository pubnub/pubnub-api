//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNIdentificationViewController.h"
#import "PNMainViewController.h"
#import "PNObservationCenter.h"
#import "PNError+Protected.h"
#import "PNPresenceEvent.h"
#import "PNMessage.h"


#pragma mark Private interface methods

@interface PNAppDelegate ()


#pragma mark - Instance methods

- (void)initializePubNubClient;


@end


#pragma mark - Public interface methods

@implementation PNAppDelegate


#pragma mark - Instance methods

- (void)initializePubNubClient {

    [PubNub setDelegate:self];

    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionObserver:self
                                                            withCallbackBlock:^(NSArray *channels,
                                                                                BOOL subscribed,
                                                                                PNError *subscriptionError) {

                                if (subscribed) {

                                    PNLog(PNLogGeneralLevel, self,
                                          @"{BLOCK-P} PubNub client subscribed on channels: %@",
                                          channels);
                                }
                                else {

                                    PNLog(PNLogGeneralLevel, self,
                                          @"{BLOCK-P} PubNub client subscription failed with error: %@",
                                          subscriptionError);
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
     /*
    // Initialize connection to PubNub service
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} CONNECTED TO: %@", origin);

        // Subscribe for channel (by default to presence observation will
        // be enabled, if it is required, than user should use another
        // method + channelWithName:shouldObservePresence: with last parameter
        // set to 'YES'
        [PubNub subscribeOnChannels:@[[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]]
       withCompletionHandlingBlock:^(NSArray *channels, BOOL connected, PNError *subscribeError) {

           if (connected) {

               PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client successfully subscribed on channels: %@", channels);
           }
           else {

               PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client failed to subscribe on %@ because of error: %@",
                     channels, subscribeError);
           }
        }];
    }
                         errorBlock:^(PNError *connectionError) {
                             
                             PNLog(PNLogGeneralLevel, self, @"{BLOCK} FAILED TO CONNECTE WITH ERROR: %@",
                                   connectionError);
                         }];
                         */
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PNIdentificationViewController  new];
    [self.window makeKeyAndVisible];
    
    [self initializePubNubClient];
    
    
    return YES;
}


#pragma mark - PubNub client delegate methods

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);


    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        PNMainViewController *mainViewController = [PNMainViewController new];
        mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.window.rootViewController presentModalViewController:mainViewController animated:YES];
    });
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client was unable to connect because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);

    /*[PubNub sendMessage:@"Hello world"
              toChannel:[channels lastObject]
    withCompletionBlock:^(PNMessageState processingState, id processingData) {

        switch (processingState) {

            case PNMessageSending:

                PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client is sending message %@ to %@",
                      (PNMessage *)processingData, ((PNMessage *)processingData).channel);
                break;

            case PNMessageSent:

                PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client successfully sent message %@ to %@",
                      (PNMessage *)processingData, ((PNMessage *)processingData).channel);
                break;

            case PNMessageSendingError:
                {
                    PNError *error = (PNError *)processingData;
                    PNMessage *message = error.associatedObject;

                    PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client failed to send message %@ because of error: %@",
                          (PNMessage *)processingData,
                          message.channel);

                    [PubNub sendMessage:@"\"Hello my lovely PubNub client\""
                              toChannel:message.channel];

                    [PubNub sendMessage:@"\"Привет всем ;)\""
                              toChannel:message.channel];
                }
                break;
        }
    }];    */
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

#pragma mark -


@end
