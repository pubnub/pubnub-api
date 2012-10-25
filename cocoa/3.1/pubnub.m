#import "pubnub.h"

@implementation Pubnub

-(Pubnub*)
    publishKey:   (NSString*) pub_key
    subscribeKey: (NSString*) sub_key
    secretKey:    (NSString*) sec_key
    sslOn:        (BOOL)      ssl_on
    origin:       (NSString*) origin
{
    pool          = [[NSAutoreleasePool alloc] init];
    self          = [super init];
    publish_key   = pub_key;
    subscribe_key = sub_key;
    secret_key    = sec_key;
    scheme        = ssl_on ? @"https" : @"http";
    host          = origin;
    subscriptions = [[NSMutableDictionary alloc] init];
    parser        = [SBJsonParser new];
    writer        = [SBJsonWriter new];

    return self;
}

+(NSString*) urlencode: (NSString*) string {
    return [string
        stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding
    ];
}
+(NSString*) md5: (NSString*) input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:
        CC_MD5_DIGEST_LENGTH * 2
    ];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

// * /publish/pub-key/sub-key/signature/channel/callback/"msg"
-(void)
    publish:  (NSString*) channel
    message:  (id)        message
    deligate: (id)        deligate
{
    NSString* message_string = [writer stringWithObject: message];

    NSString* signature = [Pubnub md5: [NSString
            stringWithFormat: @"%@/%@/%@/%@/%@",
            publish_key,
            subscribe_key,
            secret_key,
            channel,
            message_string
    ]];

    if (1500 < [message_string length]) {
        NSLog(@"Message Too Long (Over: 1500)");
        return;
    }

    [[Request alloc]
        scheme: scheme
        host:   host
        path:   [NSString
            stringWithFormat: @"/publish/%@/%@/%@/%@/0/%@",
            publish_key,
            subscribe_key,
            signature,
            [Pubnub urlencode: channel],
            [Pubnub urlencode: message_string]
        ]
        callback: [[Response alloc]
            finished: deligate
            pubnub:   self
            channel:  channel
        ]
    ];
}

-(BOOL) subscribed: (NSString*) channel {
    if ([subscriptions objectForKey: channel]) return YES;
    return NO;
}
// * /subscribe/sub-key/channel/callback/timetoken
-(void) subscribe: (NSDictionary*) args {
    NSString* channel = [args objectForKey:@"channel"];
    [[Request alloc]
        scheme: scheme
        host:   host
        path:   [NSString
            stringWithFormat: @"/subscribe/%@/%@/0/%@",
            subscribe_key,
            [Pubnub urlencode: channel],
            [args objectForKey:@"timetoken"]
        ]
        callback: [[SubscribeDelegate alloc]
            finished: [args objectForKey:@"deligate"]
            pubnub:   self
            channel:  channel
        ]
    ];
}

-(void)
    subscribe: (NSString*) channel
    deligate:  (id)        deligate
{
    if ([self subscribed: channel]) {
        NSLog( @"Already Subscribed: %@", channel );
        return;
    }

    [subscriptions setObject:@"1" forKey:channel];

    [self
        performSelector: @selector(subscribe:)
        withObject: [NSDictionary
            dictionaryWithObjectsAndKeys:
            channel,   @"channel", 
            deligate,  @"deligate", 
            @"0",      @"timetoken", 
        nil]
    ];
}


-(void) unsubscribe: (NSString*) channel {
    
}

// * /history/sub-key/channel/callback/limit
-(void)
    history:  (NSString*) channel
    limit:    (int)       limit
    deligate: (id)        deligate
{
    if (limit > 100) limit = 100;

    [[Request alloc]
        scheme: scheme
        host:   host
        path:   [NSString
            stringWithFormat: @"/history/%@/%@/0/%i",
            subscribe_key,
            [Pubnub urlencode: channel],
            limit
        ]
        callback: [[Response alloc]
            finished: deligate
            pubnub:   self
            channel:  channel
        ]
    ];
}

-(void) time: (id) deligate {
    [[Request alloc]
        scheme:   scheme
        host:     host
        path:     @"/time/0"
        callback: [[TimeDelegate alloc]
            finished: deligate
            pubnub:   self
        ]
    ];
}
@end


@implementation SubscribeDelegate
-(void) callback: (id) response {
    NSArray* response_data = [parser objectWithString: response];
    if (![pubnub subscribed: channel]) return;

    [pubnub
        performSelector: @selector(subscribe:)
        withObject: [NSDictionary
            dictionaryWithObjectsAndKeys:
            channel,                         @"channel", 
            deligate,                        @"deligate", 
            [response_data objectAtIndex:1], @"timetoken", 
        nil]
    ];

    id message;
    NSEnumerator* messages = [[response_data objectAtIndex:0]
        objectEnumerator
    ];

    while ((message = [messages nextObject])) {
        [deligate callback: message];
    }

}

-(void) fail: (id) response {
    if (![pubnub subscribed: channel]) return;

    [pubnub
        performSelector: @selector(subscribe:)
        withObject: [NSDictionary
            dictionaryWithObjectsAndKeys:
            channel,  @"channel", 
            deligate, @"deligate", 
            @"1",     @"timetoken", 
        nil]
        afterDelay: 1.0
    ];
}
@end

@implementation TimeDelegate
-(void) callback: (id) response {
    [deligate callback: [[parser objectWithString: response] objectAtIndex:0]];
}
@end

