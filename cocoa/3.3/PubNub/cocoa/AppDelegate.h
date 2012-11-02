//
//  AppDelegate.h
//  cocoa
//
//  Created by itshastra on 23/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (weak) IBOutlet NSTextFieldCell *txt;

@property (assign) IBOutlet NSWindow *window;
- (IBAction)subscribeClick:(id)sender;
- (IBAction)unsubscribeClick:(id)sender;
- (IBAction)presenceClick:(id)sender;
- (IBAction)hereNowClick:(id)sender;
- (IBAction)publishClick:(id)sender;
- (IBAction)historyClick:(id)sender;
- (IBAction)detailedHistoryClick:(id)sender;
- (IBAction)timeClick:(id)sender;
- (IBAction)uuidClick:(id)sender;


-(void) printLog:(NSString*) log;

@end
