    //
    //  ViewController.m
    //  Pubnub
    //
    //  Created by itshastra on 17/04/12.
    //  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
    //

#import "iPhoneTest.h"
#import "CEPubnub.h"
#import "SubcribeInBackground.h"

@interface iPhoneTest ()

@end


@implementation iPhoneTest
@synthesize subKeyText;
@synthesize channelText;
@synthesize startTTText;
@synthesize endTTText;
@synthesize countText;
@synthesize reverce;
@synthesize lastURLText;
@synthesize txt;


CEPubnub *pubnub;
NSString * newStrartTT=@"";
NSString * newEndTT=@"";


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString * subKey=@"";
    NSString *chhanel=@"";
    
    
    if([subKeyText.text isEqualToString:@""])
    {
        NSLog(@"Please enter subcribe key.");
        
    }else
    {
        subKey=subKeyText.text;
    }
    
    
    if([channelText.text isEqualToString:@""])
    {
        NSLog(@"Please enter channel name.");
        
    }else
    {
        chhanel= channelText.text; 
    }
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:subKey secretKey:nil   cipherKey:nil useSSL:NO];
    
	
	[pubnub setDelegate:self];
    
    for (int i=0; i<50; i++) {
        NSString *text=[NSString stringWithFormat:@"Hello World--> %d", i];
        [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:chhanel,@"channel",text,@"message", nil]];
            
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
    NSArray *mess =(NSArray *)messages;
    if([mess count] == 0)
    {
        [txt setText:[NSString stringWithFormat:@"%@",  @"No messages returned."]];
    }else{
        [txt setText:[NSString stringWithFormat:@"%@",  [messages objectAtIndex:0]]];
    }
    newStrartTT=[NSString stringWithFormat:@"%@",  [messages objectAtIndex:1]];
    newEndTT=[NSString stringWithFormat:@"%@",  [messages objectAtIndex:2]];
        //NSLog(@"newStrartTT::%@    newEndTT::%@",newStrartTT,newEndTT);
    if([newEndTT isEqualToString:@"0"] && [newStrartTT isEqualToString:@"0"] )
    {
        [txt setText:[NSString stringWithFormat:@"%@",  @"Invalid Range."]];
    }
    
}
-(void) pubnub:(CEPubnub *)pubnub didFailFetchDetailedHistoryOnChannel:(NSString *)channel withError:(id)error
{
    [txt setText:[NSString stringWithFormat:@"Fail to fetch  Detailed history on channel  : %@ with Error: %@", channel,error]];
}


- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time{
   
    
}

- (void)pubnub:(CEPubnub *)pubnub connectToChannel:(NSString *)channel{
    
}

- (void)pubnub:(CEPubnub *)pubnub disconnectFromChannel:(NSString *)channel{
   
}

- (void)pubnub:(CEPubnub *)pubnub reconnectToChannel:(NSString *)channel{
  
}

- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel
{
 
}

- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel
{
}
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}
- (IBAction)getHistoryResult:(id)sender {
    
    NSString * subKey=@"";
    NSString *chhanel=@"";
    NSMutableDictionary *myDictionary=  [[NSMutableDictionary alloc] init];

    
    if([subKeyText.text isEqualToString:@""])
    {
        txt.text=@"Please enter subcribe key.";
        return;
    }else
    {
        subKey=subKeyText.text;
    }
    
    if([channelText.text isEqualToString:@""])
    {
        txt.text=@"Please enter channel name.";
        return;
    }else
    {
       chhanel= channelText.text;
        [myDictionary setObject:chhanel forKey:@"channel"];
    }
  
    if(![startTTText.text isEqualToString:@""])
    {
        [myDictionary setObject:startTTText.text forKey:@"start"];
    }
    if(![endTTText.text isEqualToString:@""])
    {
        [myDictionary setObject:endTTText.text forKey:@"end"];
    }
    if(![countText.text isEqualToString:@""])
    {
        [myDictionary setObject:countText.text forKey:@"count"];
    }
    if([reverce isOn])
    {
        [myDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"reverse"];
    }else
    {
        [myDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"reverse"];
    }
    
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:subKey secretKey:nil   cipherKey:nil useSSL:NO];
        
	[pubnub setDelegate:self];
    
    [pubnub detailedHistory:myDictionary  ];

}

- (IBAction)clearScreen:(id)sender {
    txt.text=@"";
}

- (IBAction)nextClick:(id)sender {
    NSString * subKey=@"";
    NSString *chhanel=@"";
    NSMutableDictionary *myDictionary=  [[NSMutableDictionary alloc] init];
    
    
    if([subKeyText.text isEqualToString:@""])
    {
        txt.text=@"Please enter subcribe key.";
        return;
    }else
    {
        subKey=subKeyText.text;
    }
    
    
    if([channelText.text isEqualToString:@""])
    {
        txt.text=@"Please enter channel name.";
        return;
    }else
    {
        chhanel= channelText.text;
        [myDictionary setObject:chhanel forKey:@"channel"];
    }
   
    if(![countText.text isEqualToString:@""])
    {
        [myDictionary setObject:countText.text forKey:@"count"];
    }
     
    [myDictionary setObject:newEndTT forKey:@"start"];
    
    if([reverce isOn])
    {
       
        [myDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"reverse"];
    }else
    {
       
        [myDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"reverse"];
    }

    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:subKey secretKey:nil   cipherKey:nil useSSL:NO];
    
	
	[pubnub setDelegate:self];
    
    [pubnub detailedHistory:myDictionary  ];
    

}
- (IBAction)previusClick:(id)sender {
    NSString * subKey=@"";
    NSString *chhanel=@"";
    NSMutableDictionary *myDictionary=  [[NSMutableDictionary alloc] init];
    
    if([subKeyText.text isEqualToString:@""])
    {
        txt.text=@"Please enter subcribe key.";
        return;
    }else
    {
        subKey=subKeyText.text;
    }

    if([channelText.text isEqualToString:@""])
    {
        txt.text=@"Please enter channel name.";
        return;
    }else
    {
        chhanel= channelText.text;
        [myDictionary setObject:chhanel forKey:@"channel"];
    }
    
    [myDictionary setObject:newStrartTT forKey:@"end"];
   
    if(![countText.text isEqualToString:@""])
    {
        [myDictionary setObject:countText.text forKey:@"count"];
    }
    if([reverce isOn])
    {
        [myDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"reverse"];
    }else
    {
        [myDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"reverse"];
    }

    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:subKey secretKey:nil   cipherKey:nil useSSL:NO];
    
	[pubnub setDelegate:self];
    [pubnub detailedHistory:myDictionary  ];


}
@end
