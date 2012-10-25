//
//  CL_215.m
//  PubnubTest
//
//  Created by itshastra on 16/10/12.
//
//

#import "CL_215.h"
#import "CommonUtil.h"

@implementation CL_215
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

NSString *_publish_key ,*_subscribe_key,*_secret_key,*_cipher_key,*_uuid;
NSString *_crazy,*_channel;
BOOL _ssl_on;
CEPubnub *pubnub;

-(void) initParameter {
    _publish_key=_subscribe_key=_secret_key=_cipher_key=@"demo";
    _uuid=@"efc873ea-8512-45c2-b0c8-91c95b36a819";
    _ssl_on=NO;
    _crazy = @"~`!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
     pubnub = [[CEPubnub alloc] initWithPublishKey:_publish_key subscribeKey:_subscribe_key secretKey:_secret_key   cipherKey:_cipher_key uuid:_uuid useSSL:NO];
    
    _channel=[NSString stringWithFormat:@"%d", (int)CFAbsoluteTimeGetCurrent()];
     NSLog(@"Channel:%@",_channel);
     NSLog(@"UUID:%@",_uuid);
}

-(void)publishMessage
{
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:_channel,@"channel",_crazy,@"message", nil]];
   
}

-(void) runCL_215UnitTest
{
    [self initParameter];
    [pubnub setDelegate:[self getDelegate]];
    [pubnub subscribe: _channel];
    [self publishMessage];
   
    

}


#pragma mark -
#pragma mark CEPubnubDelegate stuff

- (void)pubnub:(CEPubnub *)pubnub
didSucceedPublishingMessageToChannel:(NSString *)channel
  withResponse:(id)response
       message:(id)message
{
    [CommonUtil LogPass:YES WithMessage:@"Message sent sucessed."];
    
}
- (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error message:(id)message// "error" may be nil
{
    NSLog(@"Publishing Error   %@ \nFor Sent Message   %@",error,message);
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidFailWithResponse:(NSString *)message onChannel:(NSString *)channel
{
    NSLog(@"Subscription Error:  %@",message);
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel{
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel{
}
- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel{
    if([message isEqualToString:_crazy])
    {
        [CommonUtil LogPass:YES WithMessage:@"Message recevied."];
    }else
    {
        [CommonUtil LogPass:NO WithMessage:@"Message recevied."];
    }
     [pubnub hereNow: _channel];
}

- (void) pubnub:(CEPubnub*)pubnub didFetchHistory:(NSArray*)messages forChannel:(NSString*)channel{
}

-(void) pubnub:(CEPubnub *)pubnub didFailFetchHistoryOnChannel:(NSString *)channel withError:(id)error{
}

-(void) pubnub:(CEPubnub *)pubnub didFetchDetailedHistory:(NSArray *)messages forChannel:(NSString *)channel{
    
}

-(void) pubnub:(CEPubnub *)pubnub didFailFetchDetailedHistoryOnChannel:(NSString *)channel withError:(id)error{
}

- (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"Time:  %f",time);
}

- (void) pubnub:(CEPubnub*)pubnub ConnectToChannel:(NSString *)channel{
    NSLog(@"Connect to Channel:   %@",channel);
}

- (void) pubnub:(CEPubnub*)pubnub DisconnectToChannel:(NSString *)channel{
    NSLog(@"Disconnect to Channel:   %@",channel);
}
- (void) pubnub:(CEPubnub*)pubnub Re_ConnectToChannel:(NSString *)channel{
    NSLog(@"Re-Connect to Channel:   %@",channel);
}

- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel{
    
}

- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel
{
    NSArray *uuids=[message objectForKey:@"uuids"];
    for (NSString *uuid in uuids) {
        if([uuid isEqualToString:_uuid])
        {
            NSLog(@"Receved UUID:%@",uuid);
            [CommonUtil LogPass:YES WithMessage:@"UUID unit test."];
        }else
        {
            [CommonUtil LogPass:NO WithMessage:@"UUID unit test."];
        }
        
    }
}


@end
