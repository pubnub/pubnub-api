//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNViewController.h"


#pragma mark Public interface methods

@implementation PNAppDelegate


#pragma mark - Instance methods

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
