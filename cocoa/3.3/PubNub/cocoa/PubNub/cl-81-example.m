#import "CEPubnubDelegate.h"
#import "CEPubnub.h"

@interface PublishResponse : NSObject <CEPubnubDelegate> @end

@implementation PublishResponse
- (void)pubnub:(CEPubnub *)pubnub didSucceedPublishingMessageToChannel:(NSString *)channel
  withResponse:(id)response
       message:(id)message
{
    NSLog(@"Sent message to PubNub channel \"%@\"  \n%@ \nSent Message:%@", channel, response,  message);
}
@end

CEPubnub *pubnub;
NSString* channelName = @"hello_world";
int main( int argc, const char *argv[] ) {
    
 // ------------------
 // Init Pubnub Object
 // ------------------
    CEPubnub *pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:nil   cipherKey:nil useSSL:NO];
	
	[pubnub setDelegate:[PublishResponse alloc]];
 // -------------------------------------
 // PubNub Publish Message (Send Message)
 // -------------------------------------
    NSLog(@"-----------PUBLISH STRING----------------");
    NSString *text=@"Hello World";
    [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:channelName,@"channel",text,@"message", nil]];
    
 // ----------------------------------
 // Run Loop for Asynchronous Requests
 // ----------------------------------
 // Only necessary when running command line application.
    [[NSRunLoop currentRunLoop] run];

    return 0;
}
