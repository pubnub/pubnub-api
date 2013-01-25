//
//  ViewController.h
//  Pubnub
//
//  Created by itshastra on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEPubnubDelegate.h"

@interface iPhoneTest : UIViewController<CEPubnubDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *subKeyText;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *channelText;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *startTTText;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *endTTText;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *countText;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *reverce;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *lastURLText;

@property (retain, nonatomic) IBOutlet UITextView *txt;

- (IBAction)getHistoryResult:(id)sender;
- (IBAction)clearScreen:(id)sender;
- (IBAction)nextClick:(id)sender;


- (IBAction)previusClick:(id)sender;


@end


