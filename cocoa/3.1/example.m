#import "pubnub.h"

// ----------------------
// Time Response Callback
// ----------------------
@interface      TimeResponse: TimeDelegate @end
@implementation TimeResponse
-(void) callback: (NSNumber*) response {
    NSLog( @"%@", response );
}
@end

// -------------------------
// Publish Response Callback
// -------------------------
@interface      PublishResponse: Response @end
@implementation PublishResponse
-(void) callback: (NSArray*) response {
    NSLog( @"%@", response );
}
-(void) fail: (id) response {
    NSLog( @"%@", response );
}
@end

// -------------------------
// History Response Callback
// -------------------------
@interface      HistoryResponse: Response @end
@implementation HistoryResponse
-(void) callback: (NSArray*) response {
    NSLog( @"%@", response );
}
@end

// ---------------------------
// Subscribe Response Callback
// ---------------------------
@interface      SubscribeResponse: Response @end
@implementation SubscribeResponse
-(void) callback: (id) response {
    NSLog( @"Received Message (channel: '%@') -> %@", channel, response );
}
@end

int main( int argc, const char *argv[] ) {
    // ------------------
    // Init Pubnub Object
    // ------------------
    Pubnub *pubnub = [[Pubnub alloc]
        publishKey:   @"demo"
        subscribeKey: @"demo"
        secretKey:    @"demo"
        sslOn:        NO
        origin:       @"pubsub.pubnub.com"
    ];

    NSString* channel = @"hello_world";

    // ----------------------------------
    // PubNub Server Time (Get TimeToken)
    // ----------------------------------
    [pubnub time: [TimeResponse alloc]];

    // -------------------------------------
    // PubNub Publish Message (Send Message)
    // -------------------------------------
    [pubnub
        publish: channel
        message: [NSArray arrayWithObjects:
            @"one",
            @"\"~`!@#$%^&*( )+=[]\\\\{}|;\':,./<>?.\"",
            @"three",
            nil
        ]
        deligate: [PublishResponse alloc]
    ];

    // ---------------------------------------
    // PubNub History (Recent Message History)
    // ---------------------------------------
    [pubnub
        history:  channel
        limit:    1
        deligate: [HistoryResponse alloc]
    ];

    // -----------------------------------
    // PubNub Subscribe (Receive Messages)
    // -----------------------------------
    NSLog( @"Listening to: %@", channel );
    [pubnub
        subscribe: channel
        deligate:  [[SubscribeResponse alloc]
            pubnub:  pubnub
            channel: channel
        ]
    ];


    // ----------------------------------
    // Run Loop for Asynchronous Requests
    // ----------------------------------
    // Only necessary when running command line application.
    [[NSRunLoop currentRunLoop] run];
    [pubnub release];

    return 0;
}
