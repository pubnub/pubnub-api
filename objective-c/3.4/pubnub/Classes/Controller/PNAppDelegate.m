//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNViewController.h"
#import "PNImports.h"


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
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub setClientIdentifier:nil];
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PNViewController  new];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

#pragma mark -


@end
