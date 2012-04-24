//
//  UIViewController+iPhoneTest.m
//  PubNub-Dev
//
//  Created by itshastra on 10/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPhoneTest.h"
#import "CEPubnub.h"
#import "Common.h"

@implementation  iPhoneTest

CEPubnub *pubnub;


- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    

	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
	UIButton *btn; // = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 50.0, 50.0)];
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(10.0, 50.0, 80.0, 50.0);
	[btn addTarget:self action:@selector(button1click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"String" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	
    
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(100.0, 50.0, 80.0, 50.0);
	[btn addTarget:self action:@selector(button2click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"Array" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	
	
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(200.0, 50.0, 100.0, 50.0);
	[btn addTarget:self action:@selector(button3click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"Dictionary" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	
    
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(10.0, 150.0, 80.0, 50.0);
	[btn addTarget:self action:@selector(button4click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"History" forState:UIControlStateNormal];
	[self.view addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(100.0, 150.0, 80.0, 50.0);
	[btn addTarget:self action:@selector(button5click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"Time" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	
	
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(200.0, 150.0, 80.0, 50.0);
	[btn addTarget:self action:@selector(button6click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"UUID" forState:UIControlStateNormal];
	[self.view addSubview:btn];
    
	UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 245.0, 600.0, 400.0)];
	txt.tag = 500;
    
	[self.view addSubview:txt];
	
/*		txt = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 250.0, 600.0, 100.0)];
	txt.tag = 600;
	[self.view addSubview:txt];*/
	
	
}
- (void)button1click: (id)sender
{
	NSLog(@"-----------PUBLISH STRING----------------");
	
 
    NSString * text=@"Hello world!";
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",text,@"message", nil]];
	

    
   
	
}
- (void)button2click: (id)sender
{
    NSLog(@"-----------PUBLISH ARRAY----------------");
	
    	[pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",[NSArray arrayWithObjects:@"seven", @"eight", [NSDictionary dictionaryWithObjectsAndKeys:@"Cheeseburger",@"food",@"Coffee",@"drink", nil], nil],@"message", nil]];
    	
}
- (void)button3click: (id)sender
{
    NSLog(@"-----------PUBLISH Dictionary----------------");
	
    
    
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",[NSDictionary dictionaryWithObjectsAndKeys:@"X-code->ÇÈ°∂@#$%^&*()!",@"Editer",@"Objective-c",@"Language", nil],@"message", nil]];
    
    
}

- (void)button4click: (id)sender
{
    NSLog(@"-----------HISTORY START----------------");
	
    
    
    //[pubnub fetchHistory:3 forChannel:@"hello_world1"];
	
    NSInteger limit = 3;
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];    
    [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", @"hello_world",@"channel",nil]];
    
   	

	
}

- (void)button5click: (id)sender
{
	//NSLog(@"button3click");
	
    NSLog(@"-----------TIME START----------------");
    [pubnub getTime];
    

}

- (void)button6click: (id)sender
{
    NSLog(@"-----------UUID START----------------");
    NSLog(@"UUID::: %@",[CEPubnub getUUID]);
   
	
		
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
      
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"   cipherKey:@"demo" useSSL:NO];
	//subscribe to a few channels
	
	[pubnub setDelegate:self];
	//[pubnub subscribe: @"test_iphone" delegate:self];
	//[pubnub subscribeToChannel:@"hello_world"];
    [pubnub subscribeToChannel: @"hello_world"];
 /*   [pubnub subscribeToChannel: @"hello_world_2"];
    [pubnub subscribeToChannel: @"hello_world_3"];*/
}



#pragma mark -
#pragma mark PubnubDelegate stuff
- (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString*)channel
{
}
- (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error// "error" may be nil
{
  NSLog(@"didFailPublishingMessageToChannel   %@",error);
}
- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel{
    
    NSLog(@"subscriptionDidReceiveDictionary   ");
    [(UITextView *)[self.view viewWithTag:500] setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
    
    NSLog(@"Sescribe   %@",message);
    
    
    NSDictionary* disc=(NSDictionary*)message;
    for (NSString* key in [disc allKeys]) {
        //   NSLog(@"Key::%@",key);
        NSString* val=(NSString*)[disc objectForKey:key];
       NSLog(@"%@-->   %@",key,val);
    }
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel{
    NSLog(@"subscriptionDidReceiveArray   ");
    NSLog(@"Sescribe   %@",message);
    [(UITextView *)[self.view viewWithTag:500] setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received\n: %@", channel, message]];
}
- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel{
    NSLog(@"subscriptionDidReceiveString   ");
    NSLog(@"Sescribe   %@",message);
    [(UITextView *)[self.view viewWithTag:500] setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
}   



- (void) pubnub:(CEPubnub*)pubnub didFetchHistory:(NSArray*)messages forChannel:(NSString*)channel{
    int i=0;
    NSLog(@"didFetchHistory");
  NSMutableString *histry=  [[NSMutableString alloc]init ];
    for (NSString * object in messages) {
         NSLog(@"%d \n%@",i,object);
        [histry appendString:[NSString stringWithFormat:@"----%i\n%@",i,object]];
        
        i++;
        
    } 
    [(UITextView *)[self.view viewWithTag:500] setText:[NSString stringWithFormat:@"History on channel (dict) : %@ - received:\n %@", channel, histry]];
   NSLog(@"Finesh didFetchHistory");
}  // "messages" will be nil on failure




- (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"didReceiveTime   %f",time );
    
    [(UITextView *)[self.view viewWithTag:500] setText:[NSString stringWithFormat:@"Time  :- received:\n %f", time]];
}  // "time" will be NAN on failure

@end
