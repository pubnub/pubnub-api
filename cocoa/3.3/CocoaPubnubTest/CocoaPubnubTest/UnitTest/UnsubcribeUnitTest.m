
//  Steps
//  1.Subscribe the channel
//  2.Publish the message.
//  3.After Send message. In subscribe callback unsubscribe the channel.
//  4.Again publish the message. 
//

#import "UnsubcribeUnitTest.h"
#import "request.h"
#import "pubnub.h"

@interface PublishCallbackForUnsubcribeUnitTest: Response
-(PublishCallbackForUnsubcribeUnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o;
@end

@implementation PublishCallbackForUnsubcribeUnitTest
-(PublishCallbackForUnsubcribeUnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o
{
    [super pubnub:pubnub_o channel:channel_o message:message_o];
    return self;
}
-(void)callback:(id)request withResponce:(id)response
{
    NSLog(@"Publish Message sucussfully on channel:%@ with responce:%@",channel,response);
}

-(void)fail:(id)request withResponce:(id)response
{
    NSLog(@"Publish Message fail on channel:%@ with responce:%@",channel,response);
}

@end

@interface SubcribeCallbackForUnsubcribeUnitTest: Response

-(SubcribeCallbackForUnsubcribeUnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o;

@end

@implementation SubcribeCallbackForUnsubcribeUnitTest

-(SubcribeCallbackForUnsubcribeUnitTest*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
message:  (id)message_o
{
    [super pubnub:pubnub_o channel:channel_o message:message_o];
    return self;
}

-(void)callback:(id)request withResponce:(id)response
{
    NSLog(@"Message recevie sucessfully....");
    NSLog(@"Unsubscribing the channel:%@",channel);
    [pubnub unsubscribe:channel];
    NSLog(@"Unsubscribe the channel:%@  sucussfully.",channel);
    
    NSLog(@"Publishing message to channel %@",channel);
    NSString *newMessage=@"Temp sample message.";
    PublishCallbackForUnsubcribeUnitTest *reponceCallback= [[PublishCallbackForUnsubcribeUnitTest alloc]
                                                            pubnub:pubnub
                                                            channel:channel
                                                            message:newMessage];
    [pubnub
     publish: channel
     message: newMessage
     delegate: reponceCallback
     ];
}

-(void)fail:(id)request withResponce:(id)response
{
      NSLog(@"Subcribe fail:%@",response);
}

@end

@implementation UnsubcribeUnitTest

NSString* channel ;
NSString* msg ;
Pubnub *pubnub;

-(void)publishMessage
{
        //Publish Message on channel
    PublishCallbackForUnsubcribeUnitTest *reponceCallback= [[PublishCallbackForUnsubcribeUnitTest alloc]
                                                            pubnub:pubnub
                                                            channel:channel
                                                            message:msg];
    NSLog(@"Publishing message to channel %@",channel);
    [pubnub
     publish: channel
     message: msg
     delegate: reponceCallback];
    
}

-(void)runUnsubcribeUnitTest
{
    pubnub = [[Pubnub alloc]
              publishKey:   @"demo"
              subscribeKey: @"demo"
              secretKey:    @"demo"
              sslOn:        NO
              origin:       @"pubsub.pubnub.com"
              ];
 	
    channel= [NSString stringWithFormat:@"%d", (int)CFAbsoluteTimeGetCurrent()] ;
    NSLog(@"Channel:%@",channel);
    msg = @" text sample message";
    SubcribeCallbackForUnsubcribeUnitTest *subcb=[[SubcribeCallbackForUnsubcribeUnitTest alloc]
                                                  pubnub:pubnub
                                                  channel:  channel
                                                  message:msg];
    
        //Subcribe the channel
    NSLog(@"Subscribed to channel  %@",channel);
    [pubnub subscribe:channel delegate:subcb];
    
    [self performSelector: @selector(publishMessage)
               withObject:  nil
               afterDelay:  3.0
     ];
}
@end
