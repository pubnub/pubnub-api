# Pubnub 3.3
---

Pubnub is an iOS ARC support Objective-C library wrapper for the Pubnub realtime messaging service [Pubnub.com](http://www.pubnub.com/).


## Using Pubnub in your project

0. Add the Cipher.h/m,Base64.h/m,JSONKit.h/m,JSONE.h/m and Common.h/m supported file to your project 

1. Add CEPubnub.h/.m to your project

2. Import CEPubnub.h to your class header

        #import "CEPubnub.h"

3. If you wish to consider connection retry interval and retry cycle settings (for example, when the network connection is temporarily lost):
Configure values in CEPubnub.m for max retry cycles (default = -1, infinite) and delay between retries in seconds (default = 5)

		#define kMinRetryInterval 5.0 //In seconds
 	 	#define kMinRetry -1

3. Make your class follow the PubNubDelegate protocol

        @interface iPhoneTest : UIViewController <CEPubnubDelegate>

4. Implement the CEPubnubDelegate methods (they are all optional):

        - (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString*)channel withResponce: (id)responce;
        - (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error message:(id)message;  // "error" may be nil
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)message onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel;
        - (void) pubnub:(CEPubnub*)pubnub didFetchHistory:(NSArray*)messages forChannel:(NSString*)channel;
        - (void) pubnub:(CEPubnub*)pubnub didFailFetchHistoryOnChannel:(NSString*)channel;
        - (void) pubnub:(CEPubnub*)pubnub didFetchDetailedHistory:(NSArray*)messages forChannel:(NSString*)channel;
		- (void) pubnub:(CEPubnub*)pubnub didFailFetchDetailedHistoryOnChannel:(NSString*)channel withError:(id)error;
        - (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time;
        - (void) pubnub:(CEPubnub*)pubnub ConnectToChannel:(NSString*)channel ;
		- (void) pubnub:(CEPubnub*)pubnub DisconnectToChannel:(NSString*)channel ;
		- (void) pubnub:(CEPubnub*)pubnub Re_ConnectToChannel:(NSString*)channel ;
		- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel;
       

5. Instantiate Pubnub in your class so you can publish and subscribe to messages and assign delegate:self:

        pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo" cipherKey:nil useSSL:NO];   // cipherKey is optional, supply nil to disable.
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


10. Get a history of messages on a channel: (Deprecated, See Detailed History Below)

        NSInteger limit = 3;
        NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];
        [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", @"hello_world",@"channel",nil]];
   
11. Detailed History: Load Previously Published Messages in Detail.
    
        [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys: aCountInt,@"count", @"hello_world",@"channel", nil]];

Required args:

	'channel' - The channel name

Optional args:

	'count' - Max number of returned results. Default and max is 100.
	'start' - Start timetoken
	'end' - End timetoken
	'reverse' - Default is false, which is oldest first. Use true to return newest first.

12. Get the time, Time receive in NSTimeInterval:

        [pubnub getTime];
        
13. Get UUID:

        NSLog(@"UUID::: %@",[CEPubnub getUUID]);
        
   
14. here_now: Ability to get count of subscribed programs to a particular channel.
		
	[pubnub here_now: @"hello_world"];
		        
15. Presence: To join a subscriber list on a channel. Callback events can be, Join - Shows availability on a channel or Leave - Disconnected to channel means removed from the list of subscribers.
		
	[pubnub presence: @"hello_world"];
		        


Tests and an example Xcode project has been included in the project which uses all the above examples.
