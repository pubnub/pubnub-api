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


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
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
@end
