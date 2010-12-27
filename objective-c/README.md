Objective-C PubNub 3.0 Real-time Cloud Push API
===============================================

PubNub Account
--------------
You must have a pubnub account to use the API.
http://www.pubnub.com/account

About PubNub
------------
PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time bidirectional
messages to web, mobile, tv, tablet and gps clients.

Objective-C Info
----------------
http://github.com/pubnub/pubnub-api/tree/master/objective-c/


PubNub Usage Code Examples
==========================

Init Pubnub Class
-----------------

    Pubnub *pubnub = [[Pubnub alloc]
        publishKey:   @"demo"
        subscribeKey: @"demo"
        secretKey:    @"demo"
        sslOn:        NO
        origin:       @"pubsub.pubnub.com"
    ];


PubNub Publish Message (Send Message)
-------------------------------------

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
            publish: channel
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
            publish: channel
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


PubNub Subscribe (Receive Messages)
-----------------------------------

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

        NSLog( @"Listening to: %@", channel );
        [pubnub
            subscribe: channel
            deligate:  [[SubscribeResponse alloc]
                pubnub:  pubnub
                channel: channel
            ]
        ];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }


PubNub History (Recent Message History)
---------------------------------------

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
            history:  channel
            limit:    10
            deligate: [HistoryResponse alloc]
        ];

        // Only necessary when running command line application.
        [[NSRunLoop currentRunLoop] run];

        // Free Pubnub
        [pubnub release];

        return 0;
    }

PubNub Server Time Example (Get TimeToken)
------------------------------------------

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


Building Application with PubNub Real-Time Cloud Push API 3.0
=============================================================

BUILDING Cocoa iOS XCode
------------------------
 1. Copy PubNub directory into your XCode Project Class Directory.
 2. #import "pubnub.h"
 3. Refer to example.m for PubNub Usage Example.

BUILDING Cocoa Command Line
---------------------------
 1. Copy PubNub directory into your Project Directory.
 2. #import "pubnub.h"
 3. Refer to example.m for PubNub Usage Example.

BUILDING Cocoa Command Line Example
-----------------------------------
    1. Run ./build-example
    2. This will build example.m with a basic test of PubNub functions.

