//
//  AppDelegate.h
//  CocoaPubnubTest
//
//  Created by itshastra on 18/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UnitTest/CL_81.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) CL_81 *cl_81_test;

- (IBAction)UnsubscribeUnitTest:(id)sender;
- (IBAction)CL_223_UnitTest:(id)sender;
- (IBAction)DetailedHistoryUbitTest:(id)sender;
- (IBAction)Catch_up_Click:(id)sender;

- (IBAction)publish_CL_81_test:(id)sender;
- (IBAction)history_81_test:(id)sender;
- (IBAction)time_81_test:(id)sender;
- (IBAction)subscribe_CL_81_test:(id)sender;
- (IBAction)unsubscribe_81_test:(id)sender;
- (IBAction)here_now_81_test:(id)sender;
- (IBAction)uuid_81_test:(id)sender;
- (IBAction) presence_81_test:(id)sender;


@end
