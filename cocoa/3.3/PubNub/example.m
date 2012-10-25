#import "pubnub.h"

 // ----------------------
 // Time Response Callback
 // ----------------------
@interface      TimeResponse: Response @end
@implementation TimeResponse
-(void) callback:(id) request withResponce:(id)response{
    NSLog( @"Time:%@", response );
}
@end

 // -------------------------
 // Publish Response Callback
 // -------------------------
@interface      PublishResponse: Response @end
@implementation PublishResponse
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"PublishResponse %@", response );
}
-(void) fail: (id) response {
    NSLog( @"PublishResponse Fail :%@", response );
}
@end

// -------------------------
// History Response Callback
// -------------------------
@interface      HistoryResponse: Response @end
@implementation HistoryResponse
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"HistoryResponse :%@", response );
}
@end

// -------------------------
// Here Now Response Callback
// -------------------------
@interface      HereNowResponse: Response @end
@implementation HereNowResponse
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"Here Now:  %@", response );
}
@end

// -------------------------
// Detailed History Response Callback
// -------------------------
@interface      DetailedHistoryResponse: Response @end
@implementation DetailedHistoryResponse
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"DetailedHistory :: %@", response );
}
@end

// ---------------------------
// Subscribe Response Callback
// ---------------------------
@interface      SubscribeResponse: Response @end
@implementation SubscribeResponse
-(void) callback:(id) request withResponce: (id) response {
    NSLog( @"Received Message (channel: '%@') -> %@", channel, response );
}
@end

// ---------------------------
// Presence Response Callback
// ---------------------------
@interface      PresenceResponse: Response @end
@implementation PresenceResponse
-(void) callback:(id) request withResponce: (id) response {
    NSLog( @"Received Presence Message (channel: '%@') -> %@", channel, response );
}
@end

 Pubnub *pubnub;
 NSString* channelName = @"hello_world";
int main( int argc, const char *argv[] ) {
    
 // ------------------
 // Init Pubnub Object
 // ------------------
    pubnub = [[Pubnub alloc]
             publishKey:   @"demo"
             subscribeKey: @"demo"
             secretKey:    @"demo"
             sslOn:        NO
             origin:       @"pubsub.pubnub.com"
             ];
    
 // ----------------------------------
 // PubNub Server Time (Get TimeToken)
 // ----------------------------------
    [pubnub time: [TimeResponse alloc]];
    
 // -----------------------------------
 // PubNub presence
 // -----------------------------------
    
    NSLog( @"Presence to: %@", channelName );
    [pubnub
     presence: channelName
     delegate:  [[PresenceResponse alloc]
	   pubnub:  pubnub
      channel: channelName
   ]
     ];
    
 // -----------------------------------
 // PubNub Subscribe (Receive Messages)
 // -----------------------------------
    NSLog( @"Listening to: %@", channelName );
    [pubnub
     subscribe: channelName
     delegate:  [[SubscribeResponse alloc]
                 pubnub:  pubnub
                 channel: channelName
                 ]
     ];
    
 // ---------------------------------------
 // Detaield PubNub History (Recent Message History)
 // ---------------------------------------
    NSInteger count = 3;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             aCountInt,@"count",
                             channelName,@"channel",
                             [DetailedHistoryResponse alloc],@"delegate",
                             nil]];
    
 // ---------------------------------------
 // PubNub History (Recent Message History)
 // ---------------------------------------
    [pubnub
     history:  channelName
     limit:    1
     delegate: [HistoryResponse alloc]
     ];
    
 // -------------------------------------
 // PubNub Publish Message (Send Message)
 // -------------------------------------
    [pubnub
     publish: channelName
     message: [NSArray arrayWithObjects:
               @"one",
               @"~`!@#$%^&*( )+=[]\\\\{}|;\':,./<>?.",
               @"three",
               nil
               ]
     delegate: [PublishResponse alloc]
     ];
    
 // -----------------------------------
 // Here Now
 // -----------------------------------
    
    [pubnub hereNow:channelName delegate:[[HereNowResponse alloc]
                                          pubnub:  pubnub
                                          channel: channelName
                                          ]];

 // -----------------------------------
 // Unsubcribe
 // -----------------------------------
    
    [pubnub
     performSelector: @selector(unsubscribe:)
     withObject:  channelName
     afterDelay: 15.0
     ];
    
 // ----------------------------------
 // Run Loop for Asynchronous Requests
 // ----------------------------------
 // Only necessary when running command line application.
    [[NSRunLoop currentRunLoop] run];

    return 0;
}
