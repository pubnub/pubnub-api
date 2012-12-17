//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNViewController.h"
#import "PNJSONSerialization.h"


#pragma mark Private interface methods

@interface PNAppDelegate ()


#pragma mark - Instance methods

- (void)initializePubNubClient;


@end


#pragma mark - Public interface methods

@implementation PNAppDelegate


#pragma mark - Instance methods

- (void)initializePubNubClient {
    
    // Performing intial PubNub client configuration
    [PubNub setupWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    
    // If identity is set to 'nil' then PubNub client
    // will provide unique identifier instead
    [PubNub setClientIdentifier:nil];
    
    
    // Initialize connection to PubNub service
    [PubNub connect];
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
    
    PNLog(@"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    
    PNLog(@"PubNub client is about to connect to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    PNLog(@"PubNub client successfully connected to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    PNLog(@"PubNub client was unable to connect because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
    
    PNLog(@"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectWithError:(PNError *)error {
    
    PNLog(@"PubNub client closed connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    PNLog(@"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    PNLog(@"PubNub client failed to subscribe because of error: %@", error);
}

#pragma mark -


@end
