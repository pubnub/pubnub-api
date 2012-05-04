//
//  ViewController.m
//  Pubnub
//
//  Created by itshastra on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPhoneTest.h"


@interface iPhoneTest ()

@end

@implementation iPhoneTest
@synthesize txt;

CEPubnub *pubnub;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"   cipherKey:@"demo" useSSL:NO];
	//subscribe to a few channels
	
	[pubnub setDelegate:self];
	
    [pubnub subscribe: @"hello_world"];
    
}

- (void)viewDidUnload
{
    [self setTxt:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)StringPublish:(id)sender {
    
	NSLog(@"-----------PUBLISH STRING----------------");
	
    
    NSString * text=@"Hello World";
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",text,@"message", nil]];
}

- (IBAction)ArrayPublish:(id)sender {
    NSLog(@"-----------PUBLISH ARRAY----------------");
    
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",[NSArray arrayWithObjects:@"seven", @"eight", [NSDictionary dictionaryWithObjectsAndKeys:@"Cheeseburger",@"food",@"Coffee",@"drink", nil], nil],@"message", nil]];
}

- (IBAction)DictionaryPublish:(id)sender {
    NSLog(@"-----------PUBLISH Dictionary----------------");
	
    
    
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",[NSDictionary dictionaryWithObjectsAndKeys:@"X-code->ÇÈ°∂@#$%^&*()!",@"Editer",@"Objective-c",@"Language", nil],@"message", nil]];
}

- (IBAction)HistoryClick:(id)sender {
    NSLog(@"-----------HISTORY START----------------");
	
    
    
    
	
    NSInteger limit = 3;
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];    
    [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", @"hello_world",@"channel",nil]];
}

- (IBAction)TimeClick:(id)sender {
    NSLog(@"-----------TIME START----------------");
    [pubnub getTime];
}

- (IBAction)UUIDClick:(id)sender {
    NSLog(@"-----------UUID START----------------");
    NSLog(@"UUID::: %@",[CEPubnub getUUID]);
}




#pragma mark -
#pragma mark CEPubnubDelegate stuff
- (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString*)channel
{
}
- (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error// "error" may be nil
{
    NSLog(@"didFailPublishingMessageToChannel   %@",error);
}
- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel{
    
    NSLog(@"subscriptionDidReceiveDictionary   ");
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
    
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
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received\n: %@", channel, message]];
}
- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel{
    NSLog(@"subscriptionDidReceiveString   ");
    NSLog(@"Sescribe   %@",message);
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
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
    [txt setText:[NSString stringWithFormat:@"History on channel (dict) : %@ - received:\n %@", channel, histry]];
    NSLog(@"Finesh didFetchHistory");
}  // "messages" will be nil on failure




- (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"didReceiveTime   %f",time );
    
    [txt setText:[NSString stringWithFormat:@"Time  :- received:\n %f", time]];
}  // "time" will be NAN on failure

- (void)dealloc {
    [txt release];
    [txt release];
    [super dealloc];
}
@end
