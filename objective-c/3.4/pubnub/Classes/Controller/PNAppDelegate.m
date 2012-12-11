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
    [PubNub setClientIdentifier:nil];
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

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
}

#pragma mark -


@end
