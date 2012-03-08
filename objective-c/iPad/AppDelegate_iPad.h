//
//  AppDelegate_iPad.h
//  PubNubLib
//
//  Created by Chad Etzel on 3/21/11.
//  Copyright 2011 Phrygian Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CEPubnub.h"
#import "CEPubnubDelegate.h"

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

