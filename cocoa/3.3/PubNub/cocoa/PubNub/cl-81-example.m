#import "CEPubnubDelegate.h"
#import "CEPubnub.h"

@interface CEPubnubResponse : NSObject <CEPubnubDelegate> @end

@implementation CEPubnubResponse

- (void)pubnub:(CEPubnub *)pubnub didSucceedPublishingMessageToChannel:(NSString *)channel
  withResponse:(id)response
       message:(id)message
{
    NSLog(@"Sent message to PubNub channel \"%@\"  \n%@ \nSent Message:%@", channel, response,  message);
}

- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"didReceiveTime   %f",time );
}

- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel
{
    NSLog(@"channel:%@   \npresence-   %@",channel,message);
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
    NSLog(@"History on channel (dict) : %@ - received:\n %@", channel, histry);
    
}

- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel
{
    NSLog(@"here_now-   %@",message);
}

@end

CEPubnub *pubnub;
NSString* channelName = @"hello_world";
int main( int argc, const char *argv[] ) {
    
 // ------------------
 // Init Pubnub Object
 // ------------------
    CEPubnub *pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:nil   cipherKey:nil useSSL:NO];
	
	[pubnub setDelegate:[CEPubnubResponse alloc]];
 
// ----------------------------------
// PubNub Server Time (Get TimeToken)
// ----------------------------------
    [pubnub getTime];
    
// -----------------------------------
// PubNub presence
// -----------------------------------
    NSLog( @"Presence to: %@", channelName );
    [pubnub presence: channelName];
    
// -----------------------------------
// PubNub Subscribe (Receive Messages)
// -----------------------------------
    NSLog( @"Listening to: %@", channelName );
    [pubnub subscribe: channelName];
    
// ---------------------------------------
// PubNub History (Recent Message History)
// ---------------------------------------
    NSInteger limit = 3;
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit];
    [pubnub fetchHistory:[NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", channelName,@"channel",nil]];
    
// -------------------------------------
// PubNub Publish Message (Send Message)
// -------------------------------------
    NSString *text=@"Hello World";
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:channelName,@"channel",text,@"message", nil]];
    
// -----------------------------------
// Here Now
// -----------------------------------
    [pubnub hereNow:channelName];
    
// -----------------------------------
// unsubscribe from all channels
// -----------------------------------
    [pubnub unsubscribeFromChannel: nil];
    
 // ----------------------------------
 // Run Loop for Asynchronous Requests
 // ----------------------------------
 // Only necessary when running command line application.
    [[NSRunLoop currentRunLoop] run];

    return 0;
}
