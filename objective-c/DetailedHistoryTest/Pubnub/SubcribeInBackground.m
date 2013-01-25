//
//  SubcribeInBackground.m
//  Pubnub
//
//  Created by itshastra on 27/11/12.
//
//

#import "SubcribeInBackground.h"

@implementation SubcribeInBackground
    @synthesize  __delegate = delegate;

    CEPubnub *pubnub1;

-(void)main {
         pubnub1 = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:nil   cipherKey:nil useSSL:NO];
	
        [pubnub1 setDelegate:delegate];
         [pubnub1 subscribe:@"channel1"];
}


- (void)makePublish
{
    for (int i= 0 ; i<5; i++) {
        NSString *text=   [NSString stringWithFormat:@"Message Send : %d",i];
      
        [pubnub1 publish:[NSDictionary dictionaryWithObjectsAndKeys:@"channel1",@"channel",text,@"message",nil]];
    }
}

@end


@implementation PubnubDelegate

#pragma mark -
#pragma mark CEPubnubDelegate stuff

- (void)pubnub:(CEPubnub *)pubnub
didSucceedPublishingMessageToChannel:(NSString *)channel
  withResponse:(id)response
       message:(id)message
{
    NSLog(@"Sent Message:%@",  message);
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
    
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel
{
    NSLog(@"Subscribe   %@",message);
    
}

- (void)pubnub:(CEPubnub *)pubnub didFetchHistory:(NSArray *)messages forChannel:(NSString *)channel{
    int i=0;
    
    NSMutableString *histry=  [NSMutableString stringWithString: @""];
    for (NSString *object in messages) {
        NSLog(@"%d \n%@",i,object);
        [histry appendString:[NSString stringWithFormat:@" %i\n%@",i,object]];
        i++;
    }
    
    
}
-(void) pubnub:(CEPubnub *)pubnub didFailFetchHistoryOnChannel:(NSString *)channel withError:(id)error
{
    NSLog(@"%@",[NSString stringWithFormat:@"Fail to fetch history on channel  : %@ with Error: %@", channel,error]);
    
}

-(void) pubnub:(CEPubnub *)pubnub didFetchDetailedHistory:(NSArray *)messages forChannel:(NSString *)channel
{
    NSMutableString *histry=  [NSMutableString stringWithString: @""];
    for (id object in messages) {
        [histry appendString:[NSString stringWithFormat:@" %@\n",object]];
    }
    NSLog(@"%@",[NSString stringWithFormat:@"History on channel (dict) : %@ - received:\n %@", channel, histry]);
    
}
-(void) pubnub:(CEPubnub *)pubnub didFailFetchDetailedHistoryOnChannel:(NSString *)channel withError:(id)error
{
    NSLog(@"didFailFetchDetailedHistoryOnChannel   %@",[NSString stringWithFormat:@"Fail to fetch  Detailed history on channel  : %@ with Error: %@", channel,error] );
}


- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"didReceiveTime   %f",time );
    
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
    
}

- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel
{
    
    NSLog(@"here_now-   %@",message);
    NSDictionary* disc=(NSDictionary*)message;
    for (NSString *key in [disc allKeys]) {
        NSString *val=(NSString *)[disc objectForKey:key];
        NSLog(@"%@-->   %@",key,val);
    }
}

@end






