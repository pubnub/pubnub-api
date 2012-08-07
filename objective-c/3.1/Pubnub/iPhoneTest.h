//
//  ViewController.h
//  Pubnub
//
//  Created by itshastra on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEPubnub.h"

@interface iPhoneTest : UIViewController<CEPubnubDelegate>
- (IBAction)StringPublish:(id)sender;
- (IBAction)ArrayPublish:(id)sender;
- (IBAction)DictionaryPublish:(id)sender;
- (IBAction)HistoryClick:(id)sender;
- (IBAction)TimeClick:(id)sender;
- (IBAction)UUIDClick:(id)sender;
- (IBAction)unitTest:(id)sender;
- (IBAction)Subscribe:(id)sender;
- (IBAction)Unsubscribe:(id)sender;

@property (retain, nonatomic) IBOutlet UITextView *txt;

@end


