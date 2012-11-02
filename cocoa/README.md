Cocoa PubNub 3.3 Real-time Cloud Push API
===============================================

**PubNub Account**

You must have a pubnub account to use the API.
[http://www.pubnub.com/account](http://www.pubnub.com/account "PubNub Account")

**About PubNub**

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time bidirectional
messages to web, mobile, TV, tablet and GPS clients.

**Objective-C Info**

The PubNub Objective C Real-time Cloud Push API runs on Cocoa Native
and Mobile Devices.  This library offers complete non-blocking asynchronous
message passing in the cloud.

The PubNub Real-time Cloud Push Service works with every mobile device
using any carrier service provider.

[http://github.com/pubnub/pubnub-api/tree/master/objective-c/](http://github.com/pubnub/pubnub-api/tree/master/objective-c/ "Objective-C PubNub 3.0 Real-time Cloud Push API")


PubNub Usage Code Examples
--------------------------

**Init Pubnub Class**


    Pubnub *pubnub = [[Pubnub alloc]
        publishKey:   @"demo"
        subscribeKey: @"demo"
        secretKey:    @"demo"
        sslOn:        NO
        origin:       @"pubsub.pubnub.com"
    ];

**PubNub Publish Message (Send Message) [Usage Example]**


    [pubnub
        publish: @"hello_world_objective_c"
        message: [NSDictionary
            dictionaryWithObjectsAndKeys:
            @"Star",    @"first_name", 
            @"Salzman", @"last_name", 
            99999,      @"awesomeness", 
        nil]
        deligate: [Response alloc]
    ];

**PubNub Publish Message (Send Message) [Full Example]**


    @interface      PublishResponse: Response @end
    @implementation PublishResponse
    -(void) callback: (NSArray*) response {
        NSLog( @"%@", response );
    }
    -(void) fail: (id) response {
        NSLog( @"%@", response );
    }
    @end

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        // NSArray Example
        [pubnub
            publish: @"hello_world_objective_c"
            message: [NSArray arrayWithObjects:
                @"one",
                @"two",
                @"three",
                nil
            ]
            deligate: [PublishResponse alloc]
        ];

        // NSDictionary Example
        [pubnub
            publish: @"hello_world_objective_c"
            message: [NSDictionary
                dictionaryWithObjectsAndKeys:
                @"Star",    @"first_name", 
                @"Salzman", @"last_name", 
                99999,      @"awesomeness", 
            nil]
            deligate: [PublishResponse alloc]
        ];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

**PubNub Subscribe (Receive Messages) [Usage Example]**


    [pubnub
        subscribe: @"hello_world_objective_c"
        deligate:  [[SubscribeResponse alloc]
            pubnub:  pubnub
            channel: @"hello_world_objective_c"
        ]
    ];

**PubNub Subscribe (Receive Messages) [Full Example]**


    @interface      SubscribeResponse: Response @end
    @implementation SubscribeResponse
    -(void) callback: (id) response {
        NSLog( @"Received Message (channel: '%@') -> %@", channel, response );
    }
    @end

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        NSLog( @"Listening to: %@", @"hello_world_objective_c" );
        [pubnub
            subscribe: @"hello_world_objective_c"
            deligate:  [[SubscribeResponse alloc]
                pubnub:  pubnub
                channel: @"hello_world_objective_c"
            ]
        ];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }


**PubNub History (Recent Message History) [Usage Example]**


    [pubnub
        history:  @"hello_world_objective_c"
        limit:    10
        deligate: [HistoryResponse alloc]
    ];

**PubNub History (Recent Message History) [Full Example]**


    @interface      HistoryResponse: Response @end
    @implementation HistoryResponse
    -(void) callback: (NSArray*) response {
        id message;
        NSEnumerator* messages = [response objectEnumerator];

        while ((message = [messages nextObject])) {
            NSLog( @"%@", message );
        }
    }
    @end

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        [pubnub
            history:  @"hello_world_objective_c"
            limit:    10
            deligate: [HistoryResponse alloc]
        ];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

**PubNub Server Time Example (Get TimeToken) [Usage Example]**


    [pubnub time: [TimeResponse alloc]];

**PubNub Server Time Example (Get TimeToken) [Full Example]**


    @interface      TimeResponse: TimeDelegate @end
    @implementation TimeResponse
    -(void) callback: (NSNumber*) response {
        NSLog( @"%@", response );
    }
    @end

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        [pubnub time: [TimeResponse alloc]];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

**PubNub Server Detailed History Example (Recent Message History) [Usage Example]**

	NSInteger count = 3;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             aCountInt,@"count",
                             channelName,@"channel",
                             [DetailedHistoryResponse alloc],@"delegate",
                             nil]];

**PubNub Server Detailed History Example [Full Example]**

 	@interface      DetailedHistoryResponse: Response @end
	@implementation DetailedHistoryResponse
	-(void) callback:(id) request withResponce:(id)response {
    	NSLog( @"DetailedHistory :: %@", response );
	}	

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        NSInteger count = 3;
    	NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    	[pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             aCountInt,@"count",
                             channelName,@"channel",
                             [DetailedHistoryResponse alloc],@"delegate",
                             nil]];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

**PubNub Server Presence Example  [Usage Example]**

	 [pubnub
     presence: channelName
     delegate: [[PresenceResponse alloc]
	   pubnub: pubnub
      channel: channelName]];

**PubNub Server Presence Example [Full Example]**

	@interface      PresenceResponse: Response @end
	@implementation PresenceResponse
	-(void) callback:(id) request withResponce: (id) response {
    	NSLog( @"Received Presence Message (channel: '%@') -> %@", channel, response );
	}
	@end	

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        [pubnub
    	 presence:channelName
     	 delegate:[[PresenceResponse alloc]
	  	   pubnub:pubnub
      	  channel:channelName]];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

**PubNub Server Here Now Example  [Usage Example]**

	 [pubnub hereNow:channelName 
			delegate:[[HereNowResponse alloc]
              pubnub:pubnub
             channel:channelName]];

**PubNub Server Here Now Example [Full Example]**

	@interface      HereNowResponse: Response @end
	@implementation HereNowResponse
	-(void) callback:(id) request withResponce:(id)response {
    	NSLog( @"Here Now:  %@", response );
	}
	@end	

    int main( int argc, const char *argv[] ) {
        Pubnub *pubnub = [[Pubnub alloc]
            publishKey:   @"demo"
            subscribeKey: @"demo"
            secretKey:    @"demo"
            sslOn:        NO
            origin:       @"pubsub.pubnub.com"
        ];

        [pubnub hereNow:channelName 
			   delegate:[[HereNowResponse alloc]
                 pubnub:pubnub
                channel:channelName]];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

Building Application with PubNub Real-Time Cloud Push API 3.3
----------------------------------------------------------------

**BUILDING Cocoa iOS XCode**

 1. Copy PubNub directory into your XCode Project Class Directory.
 2. \#import "pubnub.h"
 3. Refer to example.m for PubNub Usage Example.

**BUILDING Cocoa Command Line**

 1. Copy PubNub directory into your Project Directory.
 2. \#import "pubnub.h"
 3. Refer to example.m for PubNub Usage Example.

**BUILDING Cocoa Command Line Example**

 1. Run ./build-example
 2. This will build example.m with a basic test of PubNub functions.

