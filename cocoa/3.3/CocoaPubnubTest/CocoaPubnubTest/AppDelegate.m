//
//  AppDelegate.m
//  CocoaPubnubTest
//
//  Created by itshastra on 18/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import "AppDelegate.h"
#import "UnitTest/DetailedHistoryUnitTest.h"
#import "UnitTest/UnsubcribeUnitTest.h"
#import "UnitTest/CL_223.h"
#import "UnitTest/Catch_Up_UnitTest.h"

@implementation AppDelegate
@synthesize window;
@synthesize cl_81_test;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    cl_81_test = [[CL_81 alloc] init];
}

- (IBAction)UnsubscribeUnitTest:(id)sender {
    UnsubcribeUnitTest *unittest1= [[UnsubcribeUnitTest alloc] init];
    [unittest1 runUnsubcribeUnitTest];
   
}

- (IBAction)CL_223_UnitTest:(id)sender {
    CL_223 *cl223= [[CL_223 alloc]init];
    [cl223 runCL_223UnitTest];
}

- (IBAction)DetailedHistoryUbitTest:(id)sender {
    DetailedHistoryUnitTest *unittest= [[DetailedHistoryUnitTest alloc] init];
    [unittest runUnitTest];
    
    
}

- (IBAction)Catch_up_Click:(id)sender {
    Catch_Up_UnitTest *unittest= [[Catch_Up_UnitTest alloc] init];
    [unittest runCatch_up_UnitTest];
}

/*Objective-c tests*/
- (IBAction)publish_CL_81_test:(id)sender{
    [cl_81_test publishMessage];
}
- (IBAction)history_81_test:(id)sender{
    [cl_81_test getHistory];
}
- (IBAction)time_81_test:(id)sender{
    [cl_81_test getTime];
}
- (IBAction)subscribe_CL_81_test:(id)sender{
    [cl_81_test subscribe];
}
- (IBAction)unsubscribe_81_test:(id)sender {
    [cl_81_test unsubscribe];
}
- (IBAction)here_now_81_test:(id)sender{
    [cl_81_test here_now];
}

- (IBAction)uuid_81_test:(id)sender{
    [cl_81_test getUUID];
}

@end
