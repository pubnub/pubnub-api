//
//  Catch_Up_UnitTest.m
//  CocoaPubnubTest
//
//  Created by itshastra on 19/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import "Catch_Up_UnitTest.h"
#import "pubnub.h"
#import "CommonUtil.h"


@interface PublishCallbackForCatchUpUnitTest: Response
-(PublishCallbackForCatchUpUnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o;
@end

@implementation PublishCallbackForCatchUpUnitTest
-(PublishCallbackForCatchUpUnitTest*)
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
    NSLog(@"Next, After recevied message please disconnect internet connection. (For simulator, remove the network cable)....");
}

-(void)fail:(id)request withResponce:(id)response
{
    NSLog(@"Publish Message fail on channel:%@ with responce:%@",channel,response);
}

@end

@interface      SubscribeCatchUpResponse: Response
-(SubscribeCatchUpResponse*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o;
@end
@implementation SubscribeCatchUpResponse
-(SubscribeCatchUpResponse*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o
{
    [super pubnub:pubnub_o channel:channel_o message:message_o];
    return self;
}

-(void) callback:(id) request withResponce: (id) response {
    NSLog(@"Message Receved:%@",response);
}
-(void) connectToChannel:(NSString *)_channel
{
    NSLog(@"Connect to channel:%@",_channel);
}
-(void)reconnectToChannel:(NSString *)_channel
{
    NSLog(@"Reconnect to channel:%@",_channel);
}
-(void)disconnectFromChannel:(NSString *)_channel
{
    NSLog(@"Disconnect to channel:%@",_channel);
       
    NSLog(@"Now your client is disconnected from server... Follow steps as, 1. Publish message on same channel from another client to make sure disconnected 2. Connect to network and you should get all missing messages here.... ");

    
}
@end

@implementation Catch_Up_UnitTest

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
    _channel=@"catch_up_channel";
    NSLog(@"Channel:%@",_channel);
    NSLog(@"UUID:%@",_uuid);
}

-(void)publishMessage
{
    PublishCallbackForCatchUpUnitTest *reponceCallback= [[PublishCallbackForCatchUpUnitTest alloc]
                                                         pubnub:pubnub
                                                         channel:_channel
                                                         message:_crazy];
    [pubnub publish:_channel message:_crazy delegate:reponceCallback];
}

-(void) runCatch_up_UnitTest
{
    [self initParameter];
    SubscribeCatchUpResponse *reponceCallback= [[SubscribeCatchUpResponse alloc]
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
