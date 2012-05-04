# Pubnub
---

Pubnub is an iOS Objective-C library wrapper for the Pubnub realtime messaging service [Pubnub.com](http://www.pubnub.com/).

## Using Pubnub in your project

0. Add the Cipher.h/m,Base64.h/m,JSONKit.h/m,JSONE.h/m and Common.h/m supported file to your project 

1. Add CEPubnub.h/.m to your project

2. Import CEPubnub.h to your class header

        #import "CEPubnub.h"

3. Make your class follow the PubNubDelegate protocol

        @interface iPhoneTest : UIViewController <CEPubnubDelegate>

4. Implement the CEPubnubDelegate methods (they are all optional):

        - (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString*)channel;
        - (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)message onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel;
        - (void) pubnub:(CEPubnub*)pubnub didFetchHistory:(NSArray*)messages forChannel:(NSString*)channel;
        - (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time;
       

5. Instantiate Pubnub in your class so you can publish and subscribe to messages and assign delegate:self:

        pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"   cipherKey:@"demo" useSSL:NO];
        [pubnub setDelegate:self];

6. Publish NSString:

        NSString * text=@"My name is pubnub";[pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",text,@"message", nil]];
    
7. Publish NSArray:

        [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:@"hello_world",@"channel",[NSArray arrayWithObjects:@"seven", @"eight", 
        [NSDictionary dictionaryWithObjectsAndKeys:@"Cheeseburger",@"food",@"Coffee",@"drink", nil], nil],@"message", nil]];


8. Publish NSDictionaries:

        [pubnub publishMessage:[NSDictionary dictionaryWithObjectsAndKeys:
        @"hello_world",@"channel",
        [NSDictionary dictionaryWithObjectsAndKeys:@"X-code->ÇÈ°∂@#$%^&*()!",@"Editer",@"Objective-c",@"Language", nil],@"message",
        nil]];

9. Subscribe to multiple message channels:

        [pubnub subscribe: @"hello_world_1"];
        [pubnub subscribe: @"hello_world_2"];
        [pubnub subscribe: @"hello_world_3"];

10. Get a history of messages on a channel:

        NSInteger limit = 3;
        NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];
        [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", @"hello_world",@"channel",nil]];
   
    

11. Get the time, Time receive in NSTimeInterval:

        [pubnub getTime];
        
12. Get the Unique UUID:

        NSLog(@"UUID::: %@",[CEPubnub getUUID]);
        
13. That's it! An example iPad app has been included in the project.

## Author



