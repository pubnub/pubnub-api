//
//  CL-81.m
//  CocoaPubnubTest
//
//  Created by Igor Tryus on 30.10.12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//
#import "CL_81.h"
#import "CEPubnub.h"

@implementation CL_81

NSString *_publish_key ,*_subscribe_key,*_secret_key,*_cipher_key;
NSString *_channel;
BOOL _ssl_on;
CEPubnub *pubnub;

-(id)init
{
    [self initParameter];
    return self ;
}

-(void) initParameter {
    _publish_key=_subscribe_key=_secret_key=@"demo";
    _ssl_on=NO;
    _channel=@"hello_world";
    pubnub = [[CEPubnub alloc] initWithPublishKey:_publish_key subscribeKey:_subscribe_key secretKey:_secret_key cipherKey:nil useSSL:_ssl_on];
    [pubnub setDelegate:self];
    NSLog(@"Channel:%@",_channel);
}

-(void) publishMessage
{
    NSString *text=@"Hello World";
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:_channel,@"channel",text,@"message", nil]];
}

- (void) getHistory
{
    NSInteger limit = 3;
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];
    [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", _channel,@"channel",nil]];
}

- (void) getTime
{
    [pubnub getTime];
}

- (void) getUUID {
    NSLog(@"UUID::: %@",[CEPubnub getUUID]);
}

- (void) subscribe
{
    [pubnub subscribe: _channel];
}

- (void) presence
{
    [pubnub presence: _channel];
}

- (void) unsubscribe
{
    [pubnub unsubscribeFromChannel: _channel];
}

- (void) here_now
{
    [pubnub hereNow: _channel];
}

/* PUBLISH callbacks*/
- (void)pubnub:(CEPubnub *)pubnub didSucceedPublishingMessageToChannel:(NSString *)channel
  withResponse:(id)response
       message:(id)message
{
    NSLog(@"Sent message to PubNub channel \"%@\"  \n%@ \nSent Message:%@", channel, response,  message);
}

- (void)pubnub:(CEPubnub *)pubnub didFailPublishingMessageToChannel:(NSString *)channel
         error:(NSString *)error
       message:(id)message
{
    NSLog(@"Publishing Error   %@ \nFor Sent Message   %@", error, message);
}

/*HISTORY callbacks*/
- (void)pubnub:(CEPubnub *)pubnub didFetchHistory:(NSArray *)messages forChannel:(NSString *)channel{
    int i=0;
    
    NSMutableString *histry=  [NSMutableString stringWithString: @""];
    for (NSString *object in messages) {
        NSLog(@"%d \n%@",i,object);
        [histry appendString:[NSString stringWithFormat:@" %i\n%@",i,object]];
        i++;
    }
    NSLog(@"History on channel (dict) : %@ - received:\n %@", channel, histry);
    
}
-(void) pubnub:(CEPubnub *)pubnub didFailFetchHistoryOnChannel:(NSString *)channel withError:(id)error
{
    NSLog(@"Fail to fetch history on channel  : %@ with Error: %@", channel,error);
}

/*TIME callback*/
- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"didReceiveTime   %f",time );
}

/* SUBSCRIBE callbacks*/
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)message
     onChannel:(NSString *)channel
{
    NSLog(@"Subscription Error:  %@",message);
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel
{
    NSLog(@"Subscribe   %@",message);
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
}

/*HERE NOW callback*/

- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel
{
    NSLog(@"here_now-   %@",message);
}

@end
