//
//  CL_223.m
//  CocoaPubnubTest
//
//  Created by itshastra on 18/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import "CL_223.h"
#import "pubnub.h"
#import "CommonUtil.h"

@interface PublishCallbackForCL_223UnitTest: Response
-(PublishCallbackForCL_223UnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o;
@end

@implementation PublishCallbackForCL_223UnitTest
-(PublishCallbackForCL_223UnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o
{
    [super pubnub:pubnub_o channel:channel_o message:message_o];
    return self;
}
-(void)callback:(id)request withResponce:(id)response
{
    [CommonUtil LogPass:YES WithMessage:@"Message sent sucessed."];
}

-(void)fail:(id)request withResponce:(id)response
{
    NSLog(@"Publish Message fail on channel:%@ with responce:%@",channel,response);
}

@end

@interface      HereNowResponse: Response @end
@implementation HereNowResponse
-(void) callback:(id) request withResponce:(id)response {
    NSArray *uuids=[response objectForKey:@"uuids"];
    for (NSString *uuid in uuids) {
        if([uuid isEqualToString:@"efc873ea-8512-45c2-b0c8-91c95b36a819"])//Check hardcode uuid
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

@interface SubcribeCallbackForCL_223UnitTest: Response

-(SubcribeCallbackForCL_223UnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o;

@end

@implementation SubcribeCallbackForCL_223UnitTest

-(SubcribeCallbackForCL_223UnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o
{
    [super pubnub:pubnub_o channel:channel_o message:message_o];
    return self;
}

-(void)callback:(id)request withResponce:(id)response
{
    if([message isEqualToString:response])
    {
        [CommonUtil LogPass:YES WithMessage:@"Message recevied."];
    }else
    {
        [CommonUtil LogPass:NO WithMessage:@"Message recevied."];
    }
    [pubnub hereNow:channel delegate:[[HereNowResponse alloc]
                                          pubnub:  pubnub
                                          channel: channel
                                          ]];
}

-(void)fail:(id)request withResponce:(id)response
{
    NSLog(@"Subcribe fail:%@",response);
}

@end

@implementation CL_223

NSString *_publish_key ,*_subscribe_key,*_secret_key,*_cipher_key,*_uuid;
NSString *_crazy,*_channel;
BOOL _ssl_on;
Pubnub *pubnub;

-(void) initParameter {
    _publish_key=_subscribe_key=_secret_key=@"demo";
    _uuid=@"efc873ea-8512-45c2-b0c8-91c95b36a819";
    _ssl_on=NO;
    _crazy = @"~!@#$%^&*( )+=[]{}|;:,./<>?.";
    pubnub = [[Pubnub alloc]
              publishKey:   _publish_key
              subscribeKey: _subscribe_key
              secretKey:    _secret_key
              sslOn:         NO
              uuid:         _uuid 
              origin:       @"pubsub.pubnub.com"
              ];
    _channel=[NSString stringWithFormat:@"%d", (int)CFAbsoluteTimeGetCurrent()];
    NSLog(@"Channel:%@",_channel);
    NSLog(@"UUID:%@",_uuid);
}

-(void)publishMessage
{
    PublishCallbackForCL_223UnitTest *reponceCallback= [[PublishCallbackForCL_223UnitTest alloc]
                                                                                pubnub:pubnub                                                                                                                                        channel:  _channel                                                            message:_crazy];
    [pubnub publish:_channel message:_crazy delegate:reponceCallback];
    
}
-(void) runCL_223UnitTest
{
    [self initParameter];
    SubcribeCallbackForCL_223UnitTest *reponceCallback= [[SubcribeCallbackForCL_223UnitTest alloc]
                                                          pubnub:pubnub
                                                         channel:_channel
                                                         message:_crazy];
    
    [pubnub subscribe: _channel delegate:reponceCallback];
    [self performSelector: @selector(publishMessage)
          withObject:  nil
          afterDelay:  3.0
          ];
}
@end
