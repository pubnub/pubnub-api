//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNViewController.h"
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

    // Performing initial PubNub client configuration
    [PubNub setupWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    
    // If identity is set to 'nil' then PubNub client
    // will provide unique identifier instead
    [PubNub setClientIdentifier:nil];
    
    // Initialize connection to PubNub service
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} CONNECTED TO: %@", origin);

        // Subscribe for channel (by default to presence observation will
        // be enabled, if it is required, than user should use another
        // method + channelWithName:shouldObservePresence: with last parameter
        // set to 'YES'
        [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev"]
       withCompletionHandlingBlock:^(NSArray *channels, BOOL connected, PNError *subscribeError) {

           if (connected) {

               PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to: %@", channels);
           }
           else {

               PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe on %@ because of error: %@",
                     channels, subscribeError);
           }
        }];
    }
                         errorBlock:^(PNError *connectionError) {
                             
                             PNLog(PNLogGeneralLevel, self, @"{BLOCK} FAILED TO CONNECTE WITH ERROR: %@",
                                   connectionError);
                         }];
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PNViewController  new];
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

    [PubNub requestServerTimeTokenWithCompletionBlock:^(NSString *timeToken, PNError *error) {

        if (error == nil) {

            PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client successfully fetched time token: %@", timeToken);
        }
        else {

            PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client failed to recieve time token because of error: "
                    "%@", error);
        }
    }];
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

    [PubNub sendMessage:@"Hello world" toChannel:[channels lastObject] withCompletionBlock:^(PNMessage *message,
                                                                                             BOOL sent,
                                                                                             PNError *sendingError) {

        if (sent) {

            PNLog(PNLogGeneralLevel, @"PubNub client successfully sent message %@ to %@",
                  message, message.channel);
        }
        else {

            PNLog(PNLogGeneralLevel, @"PubNub client failed to send message %@ because of error: %@",
                  message, sendingError);
        }
    }];
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSString *)timeToken {

    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message %@ because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

#pragma mark -


@end
