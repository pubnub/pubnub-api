//
//  ViewController.h
//  Test1
//
//  Created by itshastra on 20/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEPubnub.h"

@interface ViewController : UIViewController<CEPubnubDelegate>
- (IBAction)unit_test_CL148:(id)sender;
- (IBAction)presenceLeaveClick:(id)sender;

@end

