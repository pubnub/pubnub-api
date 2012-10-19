//
//  AppDelegate.h
//  CocoaPubnubTest
//
//  Created by itshastra on 18/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)UnsubscribeUnitTest:(id)sender;
- (IBAction)CL_223_UnitTest:(id)sender;
- (IBAction)DetailedHistoryUbitTest:(id)sender;
- (IBAction)Catch_up_Click:(id)sender;

@end
