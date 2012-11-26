    //
    //  ViewController.m
    //  Pubnub
    //
    //  Created by itshastra on 17/04/12.
    //  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
    //

#import "iPhoneTest.h"
#import "CEPubnub.h"

@interface iPhoneTest ()

@end
@interface unitTestDelegates:NSObject<CEPubnubDelegate>
    @property (strong) id<CEPubnubDelegate> delHolder;

-(id)getDelegate;
@end

@implementation iPhoneTest
@synthesize txt;

NSString *channelName;
CEPubnub *pubnub;
- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
    channelName=@"hello_world";
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:nil   cipherKey:nil useSSL:NO];
        //subscribe to a few channels
	
	[pubnub setDelegate:self];
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
    NSString *text=@"Hello World";
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:channelName,@"channel",text,@"message", nil]];
}

- (IBAction)ArrayPublish:(id)sender {
    NSLog(@"-----------PUBLISH ARRAY----------------");
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:channelName,@"channel",[NSArray arrayWithObjects:@"seven", @"eight", [NSDictionary dictionaryWithObjectsAndKeys:@"Cheeseburger",@"food",@"Coffee",@"drink", nil], nil],@"message", nil]];
}

- (IBAction)DictionaryPublish:(id)sender {
    NSLog(@"-----------PUBLISH Dictionary----------------");
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:channelName,@"channel",[NSDictionary dictionaryWithObjectsAndKeys:@"X-code->ÇÈ°∂@#$%^&*()!",@"Editer",@"Objective-c",@"Language", nil],@"message", nil]];
}

- (IBAction)HistoryClick:(id)sender {
    NSLog(@"-----------HISTORY ----------------");
    NSInteger limit = 3;
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];    
    [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", channelName,@"channel",nil]];
}

- (IBAction)TimeClick:(id)sender {
    NSLog(@"-----------TIME START----------------");
    [pubnub getTime];
}

- (IBAction)UUIDClick:(id)sender {
    NSLog(@"-----------UUID START----------------");
    NSLog(@"UUID::: %@",[CEPubnub getUUID]);
}

- (IBAction)unitTest:(id)sender {
    [self unitTest];
}

- (IBAction)Subscribe:(id)sender {
    [pubnub subscribe: channelName];  
}

- (IBAction)Unsubscribe:(id)sender {
    [pubnub unsubscribeFromChannel: channelName];  
    
}

- (IBAction)Here_Now:(id)sender {
     [pubnub hereNow: channelName];
}

- (IBAction)Presence:(id)sender {
    [pubnub presence: channelName]; 
}

- (IBAction)DetailedHistoryClick:(id)sender {
     NSLog(@"-----------Detailed History ----------------");
    NSInteger count = 3;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             aCountInt,@"count",
                             channelName,@"channel",
                             nil]];
}

    //=========================================================================
    //Unit-Test
    //=========================================================================

NSString *publish_key = @"demo", *subscribe_key = @"demo";
NSString *secret_key = @"demo", *cipher_key = nil;
BOOL ssl_on = false;
NSMutableArray *many_channels;
NSMutableDictionary *status;
    // -----------------------------------------------------------------------
	// Command Line Options Supplied PubNub
	// -----------------------------------------------------------------------

CEPubnub *pubnub_user_supplied_options ;

	// -----------------------------------------------------------------------
	// High Security PubNub
	// -----------------------------------------------------------------------
CEPubnub *pubnub_high_security ;
CEPubnub *_pubnubtemp;

- (void)unitTest
{
    pubnub_high_security = [[CEPubnub alloc] initWithPublishKey:@"pub-c-a30c030e-9f9c-408d-be89-d70b336ca7a0" subscribeKey:@"sub-c-387c90f3-c018-11e1-98c9-a5220e0555fd" secretKey:@"sec-c-MTliNDE0NTAtYjY4Ni00MDRkLTllYTItNDhiZGE0N2JlYzBl" cipherKey:@"YWxzamRmbVjFaa05HVnGFqZHM3NXRBS73jxmhVMkjiwVVXV1d5UrXR1JLSkZFRrWVd4emFtUm1iR0TFpUZvbiBoYXMgYmVlbxWkhNaF3uUi8kM0YkJTEVlZYVFjBYijFkWFIxSkxTa1pGUjd874hjklaTFpUwRVuIFNob3VsZCB5UwRkxUR1J6YVhlQWaV1ZkNGVH32mDkdho3pqtRnRVbTFpUjBaeGUgYXNrZWQtZFoKjda40ZWlyYWl1eXU4RkNtdmNub2l1dHE2TTA1jd84jkdJTbFJXYkZwWlZtRnKkWVrSRhhWbFpZVmFzc2RkZmTFpUpGa1dGSXhTa3hUYTFwR1Vpkm9yIGluZm9ybWFNfdsWQdSiiYXNWVXRSblJWYlRGcFVqQmFlRmRyYUU0MFpXbHlZV2wxZVhVNFJrTnR51YjJsMWRIRTJUW91ciBpbmZvcm1hdGliBzdWJtaXR0ZWQb3UZSBhIHJlc3BvbnNlLCB3ZWxsIHJlVEExWdHVybiB0am0aW9uIb24gYXMgd2UgcG9zc2libHkgY2FuLuhcFe24ldWVnsdSaTFpU3hVUjFKNllWaFdhRmxZUWpCaQo34gcmVxdWlGFzIHNveqQl83snBfVl3" useSSL:false];
    
    pubnub_user_supplied_options = [[CEPubnub alloc] initWithPublishKey:publish_key subscribeKey:subscribe_key secretKey:secret_key   cipherKey:cipher_key useSSL:ssl_on];
    _pubnubtemp = pubnub_user_supplied_options;
    many_channels= [[NSMutableArray alloc] init]; 
    for (int i=0; i<4; i++) {
        [many_channels addObject:[[NSString alloc]initWithFormat:@"channel_%d",i]];
    }
    status=[[NSMutableDictionary alloc] init];
    [status setObject:[NSNumber numberWithInt:0] forKey:@"sent"];
    [status  setObject:[NSNumber numberWithInt:0] forKey:@"received"];
    [status  setObject:[NSNumber numberWithInt:0] forKey:@"connections"];
    
    
    unitTestDelegates *del= [[unitTestDelegates alloc] init] ;
    [_pubnubtemp setDelegate:[del getDelegate] ];
    
    
    for (NSString *channel in many_channels) {
        [_pubnubtemp subscribe:channel];
        [NSThread sleepForTimeInterval:5];

    }
}

    //========================================================================
#pragma mark -
#pragma mark CEPubnubDelegate stuff

- (void)pubnub:(CEPubnub *)pubnub
    didSucceedPublishingMessageToChannel:(NSString *)channel
    withResponse:(id)response
    message:(id)message
{
    NSLog(@"Sent message to PubNub channel \"%@\"  \n%@ \nSent Message:%@", channel, response,  message);
}

// "error" may be nil
- (void)pubnub:(CEPubnub *)pubnub
    didFailPublishingMessageToChannel:(NSString *)channel
    error:(NSString *)error
    message:(id)message
{
    NSLog(@"Publishing Error   %@ \nFor Sent Message   %@", error, message);
}


- (void)pubnub:(CEPubnub *)pubnub
    subscriptionDidFailWithResponse:(NSString *)message
    onChannel:(NSString *)channel
{
    NSLog(@"Subscription Error:  %@",message);
}

- (void)pubnub:(CEPubnub *)pubnub
    subscriptionDidReceiveDictionary:(NSDictionary *)message
    onChannel:(NSString *)channel
{
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
    NSLog(@"Subscribe   %@",message);
    NSDictionary* disc=(NSDictionary*)message;
    for (NSString *key in [disc allKeys]) {
        NSString *val=(NSString *)[disc objectForKey:key];
        NSLog(@"%@-->   %@",key,val);
    }
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel
{
    NSLog(@"Subscribe   %@",message);
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received\n: %@", channel, message]];
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel
{
    NSLog(@"Subscribe   %@",message);
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
}

- (void)pubnub:(CEPubnub *)pubnub didFetchHistory:(NSArray *)messages forChannel:(NSString *)channel{
    int i=0;

    NSMutableString *histry=  [NSMutableString stringWithString: @""];
    for (NSString *object in messages) {
        NSLog(@"%d \n%@",i,object);
        [histry appendString:[NSString stringWithFormat:@" %i\n%@",i,object]];
        i++;
    }
    [txt setText:[NSString stringWithFormat:@"History on channel (dict) : %@ - received:\n %@", channel, histry]];

}
-(void) pubnub:(CEPubnub *)pubnub didFailFetchHistoryOnChannel:(NSString *)channel withError:(id)error
{
    [txt setText:[NSString stringWithFormat:@"Fail to fetch history on channel  : %@ with Error: %@", channel,error]];
}

-(void) pubnub:(CEPubnub *)pubnub didFetchDetailedHistory:(NSArray *)messages forChannel:(NSString *)channel
{
    NSMutableString *histry=  [NSMutableString stringWithString: @""];
    for (id object in messages) {
        [histry appendString:[NSString stringWithFormat:@" %@\n",object]];
    }
    [txt setText:[NSString stringWithFormat:@"History on channel (dict) : %@ - received:\n %@", channel, histry]];
}
-(void) pubnub:(CEPubnub *)pubnub didFailFetchDetailedHistoryOnChannel:(NSString *)channel withError:(id)error
{
    [txt setText:[NSString stringWithFormat:@"Fail to fetch  Detailed history on channel  : %@ with Error: %@", channel,error]];
}


- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"didReceiveTime   %f",time );
    [txt setText:[NSString stringWithFormat:@"Time  :- received:\n %f", time]];
}

- (void)pubnub:(CEPubnub *)pubnub connectToChannel:(NSString *)channel{
    NSLog(@"Connect to Channel:   %@",channel);
}

- (void)pubnub:(CEPubnub *)pubnub disconnectFromChannel:(NSString *)channel{
    NSLog(@"Disconnect to Channel:   %@",channel);
}

- (void)pubnub:(CEPubnub *)pubnub reconnectToChannel:(NSString *)channel{
    NSLog(@"Re-Connect to Channel:   %@",channel);
}

- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel
{
    NSLog(@"channel:%@   \npresence-   %@",channel,message);
    NSDictionary* disc=(NSDictionary*)message;
    for (NSString *key in [disc allKeys]) {
        NSString *val=(NSString *)[disc objectForKey:key];
        NSLog(@"%@-->   %@",key,val);
    }
    [txt setText:[NSString stringWithFormat:@"Presence received on channel %@:-\n %@",channel, message]];
}

- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel
{
    [txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
    NSLog(@"here_now-   %@",message);
    NSDictionary* disc=(NSDictionary*)message;
    for (NSString *key in [disc allKeys]) {
        NSString *val=(NSString *)[disc objectForKey:key];
        NSLog(@"%@-->   %@",key,val);
    }
}

- (void)pubnub:(CEPubnub *)pubnub maxRetryAttemptCompleted:(NSString *)channel
{
    NSLog(@"Max Retry Attempt Completed  Channel:%@",channel);
}
@end


@implementation unitTestDelegates

@synthesize delHolder;

-(id)getDelegate
{
    return delHolder;
}

-(id)init
{
    delHolder=self;
    return self ;
}

-(void)test:(BOOL)state message:(NSString *)message
{
    if(state) {
        NSLog(@"PASS - %@", message);
    } else {
        NSLog(@" FAIL - %@" ,message);
    }
}

- (void)pubnub:(CEPubnub *)pubnub
    didSucceedPublishingMessageToChannel:(NSString *)channel
    withResponse:(id)response
    message:(id)message
{
    [self test:YES message:[NSString stringWithFormat:@"Publish of channel:%@",channel]];
    
    NSNumber *sent = (NSNumber*) [status objectForKey:@"sent"];
    [status removeObjectForKey:@"sent"];
    [status setObject:[NSNumber numberWithInt:sent.intValue +1] forKey:@"sent"];
    
}
- (void)pubnub:(CEPubnub *)pubnub
    didFailPublishingMessageToChannel:(NSString *)channel error:(NSString *)error message:(id)message
{
    [self test:NO message:[NSString stringWithFormat:@"Publish of channel:%@",channel]];
}
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel{
    
    NSNumber *sent = (NSNumber*) [status objectForKey:@"sent"];
    NSNumber *received = (NSNumber*) [status objectForKey:@"received"];
    [self test:received.intValue <= sent.intValue message:@"many sends"];
    [status removeObjectForKey:@"received"];
    [status setObject:[NSNumber numberWithInt:received.intValue +1] forKey:@"received"];
    [_pubnubtemp unsubscribeFromChannel:channel];
    NSInteger limit = 3;
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];    
    [_pubnubtemp fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", channel,@"channel",nil]];
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel{
    NSLog(@"Subscribe   %@",message);
}
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel{
    NSLog(@"Subscribe   %@",message);
}   

- (void)pubnub:(CEPubnub *)pubnub didFetchHistory:(NSArray *)messages forChannel:(NSString *)channel{
    [self test:YES message:[NSString stringWithFormat:@"Fetch Histry of channel:%@",channel]];
}

- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time
{
    NSLog(@"didReceiveTime   %f",time );
}  

- (void)pubnub:(CEPubnub *)pubnub connectToChannel:(NSString *)channel
{
    NSLog(@"Connect to Channel:   %@",channel);
    NSNumber *connections = (NSNumber*) [status objectForKey:@"connections"];
    [status removeObjectForKey:@"connections"];
    [status setObject:[NSNumber numberWithInt:connections.intValue +1] forKey:@"connections"];
    [_pubnubtemp publish:[NSDictionary dictionaryWithObjectsAndKeys:channel,@"channel",[NSDictionary dictionaryWithObjectsAndKeys:@"X-code->ÇÈ°∂@#$%^&*()!",@"Editer",@"Objective-c",@"Language", nil],@"message", nil]];
}  

- (void)pubnub:(CEPubnub *)pubnub disconnectFromChannel:(NSString *)channel
{
    NSLog(@"Disconnect to Channel:   %@",channel);
} 

- (void)pubnub:(CEPubnub *)pubnub reconnectToChannel:(NSString *)channel
{
    NSLog(@"Re-Connect to Channel:   %@",channel);
}

@end

