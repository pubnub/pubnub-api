//
//  ViewController_UnitTestController.h
//  Test1
//
//  Created by itshastra on 20/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "CEPubnub.h"
@interface UnitTestController : UIViewController<CEPubnubDelegate>
@property (retain, nonatomic) IBOutlet UITextView *messageText;
@property (retain, nonatomic) IBOutlet UITextView *responceText;


- (IBAction)continueClick:(id)sender;
@end
