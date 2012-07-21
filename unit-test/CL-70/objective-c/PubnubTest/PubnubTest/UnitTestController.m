//
//  ViewController_UnitTestController.h
//  Test1
//
//  Created by itshastra on 20/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UnitTestController.h"


@interface UnitTestController ()

@end

@implementation UnitTestController
@synthesize responceText;
@synthesize messageText;

    CEPubnub *pubnub;
- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
    
          pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"   cipherKey:@"demo" useSSL:NO];
        //subscribe to a few channels
	
        [pubnub setDelegate:self];
}

- (void)viewDidUnload
{
    [self setMessageText:nil];
    [self setResponceText:nil];
    [super viewDidUnload];
        // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)continueClick:(id)sender {
     [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",[NSDictionary dictionaryWithObjectsAndKeys:@"X-code!",@"Editer",@"Objective-c",@"Language", nil],@"message", nil]];
}

#pragma mark -
#pragma mark CEPubnubDelegate stuff
- (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString *)channel withResponce:(id)responce
{
    NSLog(@"Sent message to PubNub channel \"%@\" ", channel); 
    NSString * str=[NSString stringWithFormat:@"Message send sucessfully. to PubNub channel :%@\n%@", channel,(NSArray*)responce];
    responceText.text=str;
    messageText.text=@"Please disconnect the computer from the Internet, and click to Continue.";
}
- (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error// "error" may be nil
{
    NSLog(@"Publishing Error   %@",error);
    NSString * str=[NSString stringWithFormat:@"Message send Fail. to PubNub channel :%@\n%@", channel,(NSArray*)error];
      responceText.text=str;
    messageText.text=@"Please confirm that the Internet is connected, and click to Continue.";
}



   




@end
