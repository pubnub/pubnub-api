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
    current_uuid  = [Pubnub uuid];
    
    _connections= [[NSMutableDictionary alloc] init];
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

+ (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = ( NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

// * /publish/pub-key/sub-key/signature/channel/callback/"msg"
-(void)
    publish:  (NSString*) channel
    message:  (id)        message
    delegate: (id)        delegate
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
        callback: delegate
        channel:  channel
    ];
}

-(BOOL) subscribed: (NSString*) channel {
    if ([subscriptions objectForKey: channel]) return YES;
    return NO;
}
// * /subscribe/sub-key/channel/callback/timetoken
-(void) subscribe: (NSDictionary*) args {
    NSString* channel = [args objectForKey:@"channel"];
   Request * request=  [[Request alloc]
        scheme: scheme
        host:   host
        path:   [NSString
            stringWithFormat: @"/subscribe/%@/%@/0/%@/?uuid=%@",
            subscribe_key,
            [Pubnub urlencode: channel],
            [args objectForKey:@"timetoken"],
            current_uuid
        ]
        callback: [[SubscribeDelegate alloc]
            finished: [args objectForKey:@"delegate"]
            pubnub:   self
            channel:  channel
        ] channel:  channel
    ];
    
    [_connections setObject:request forKey:channel];
}

-(void)
    subscribe: (NSString*) channel
    delegate:  (id)        delegate
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
            delegate,  @"delegate", 
            @"0",      @"timetoken", 
        nil]
    ];
}

- (void)detailedHistory:(NSDictionary * )arg1 {
    
    NSString *channel;
    id delegate;
    
    if (![arg1 objectForKey:@"channel"])
    {
        NSLog(@"ERROR::Channel name not found.");
        return;
    }else
    {
        channel=[arg1 objectForKey:@"channel"];
    }
    
    if (![arg1 objectForKey:@"delegate"])
    {
        NSLog(@"ERROR::Delegate not found.");
        return;
    }else
    {
        delegate=[arg1 objectForKey:@"delegate"];
    }
    
    NSMutableString *parameters= [[NSMutableString alloc]init];
    
    
    
    if ([arg1 objectForKey:@"count"])
    {
        [parameters appendFormat:@"count=%@",[arg1 objectForKey:@"count"]];
    }else
    {
        [parameters appendString:@"count=100"];
    }
    
    if ([arg1 objectForKey:@"start"])
    {
        if ([parameters length] > 0) {
            [parameters appendString:@"&"];
        }
        [parameters appendFormat:@"start=%@",[arg1 objectForKey:@"start"]];
    }
    
    if ([arg1 objectForKey:@"end"])
    {
        if ([parameters length] > 0) {
            [parameters appendString:@"&"];
        }
        [parameters appendFormat:@"end=%@",[arg1 objectForKey:@"end"]];
    }
    
    if ([arg1 objectForKey:@"reverse"])
    {
        if ([parameters length] > 0) {
            [parameters appendString:@"&"];
        }
        BOOL reverse=[[arg1 objectForKey:@"reverse"] boolValue];
        if(reverse)
            [parameters appendFormat:@"reverse=%@",@"true"];
        else
            [parameters appendFormat:@"reverse=%@",@"false"];
    }
    
    if ([parameters length] > 0) {
        [parameters insertString:@"?" atIndex:0 ];
    }
    
    [[Request alloc]
     scheme: scheme
     host:   host
     path:   [NSString
              stringWithFormat: @"/v2/history/sub-key/%@/channel/%@%@",
              subscribe_key,
              [Pubnub urlencode: channel],
              [parameters description]
              ]
     callback: [[Response alloc]
                finished: delegate
                pubnub:   self
                channel:  channel
                ]   channel:channel
     ];
    
}

- (void)
    hereNow:(NSString *)channel
    delegate: (id)delegate
{
    if(channel == nil || channel == @"")
    {
        NSLog(@"Missing channel");
        return;
    }
    
    [[Request alloc]
     scheme: scheme
     host:   host
     path:   [NSString
              stringWithFormat: @"/v2/presence/sub_key/%@/channel/%@",
              subscribe_key,
              [Pubnub urlencode: channel]        
              ]
     callback: [[Response alloc]
                finished: delegate
                pubnub:   self
                channel:  channel
                ]   channel:channel
     ];
    
    
}


-(void) unsubscribe: (NSString*) channel {

    Request *_req = [_connections objectForKey:channel];
    
    [_req.connection cancel];
    [_connections removeObjectForKey:channel];
    [subscriptions removeObjectForKey:channel];
    
}

-(void) removeConnection: (NSString*) channel{
     [_connections removeObjectForKey:channel];
}

// * /history/sub-key/channel/callback/limit
-(void)
    history:  (NSString*) channel
    limit:    (int)       limit		
    delegate: (id)        delegate
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
            finished: delegate
            pubnub:   self
            channel:  channel
        ]   channel:channel
    ];
}

-(void) time: (id) delegate {
    [[Request alloc]
        scheme:   scheme
        host:     host
        path:     @"/time/0"
        callback: [[TimeDelegate alloc]
            finished: delegate
            pubnub:   self
        ] channel:nil
    ];
}


-(void)
presence: (NSString*) channel
delegate:  (id)        delegate
{
    if ([self subscribed: [NSString stringWithFormat:@"%@-pnpres", channel]]) {
        NSLog( @"Already running presence: %@", channel );
        return;
    }
    
    [subscriptions setObject:@"1" forKey:[NSString stringWithFormat:@"%@-pnpres", channel]];
    
    [self
     performSelector: @selector(presence:)
     withObject: [NSDictionary
                  dictionaryWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@-pnpres", channel], @"channel" ,
                  delegate,  @"delegate",
                  @"0",      @"timetoken",
                  nil]
     ];
}


-(void) presence: (NSDictionary*) args {
    NSString* channel = [args objectForKey:@"channel"];
    [[Request alloc]
     scheme: scheme
     host:   host
     path:   [NSString
              stringWithFormat: @"/subscribe/%@/%@/0/%@/?uuid=%@",
              subscribe_key,
              [Pubnub urlencode: channel],
              [args objectForKey:@"timetoken"],
              current_uuid
              ]
     callback: [[PresenceDelegate alloc]
                finished: [args objectForKey:@"delegate"]
                pubnub:   self
                channel:  channel
                ] channel:channel
     ];
}

@end


@implementation SubscribeDelegate
-(void) callback:(NSURLConnection *)connection withResponce:(id)response {
    NSArray* response_data = [parser objectWithString: response];
    if (![pubnub subscribed: channel]) return;
    
    [pubnub
     performSelector: @selector(subscribe:)
     withObject: [NSDictionary
                  dictionaryWithObjectsAndKeys:
                  channel,                         @"channel",
                  delegate,                        @"delegate",
                  [response_data objectAtIndex:1], @"timetoken",
                  nil]
     ];
    
    id message;
    NSEnumerator* messages = [[response_data objectAtIndex:0]
                              objectEnumerator
                              ];
    
    while ((message = [messages nextObject])) {
        [delegate callback:connection withResponce:message ];
    }
    
}

-(void) fail:(NSURLConnection *)connection withResponce: (id) response {
    if (![pubnub subscribed: channel]) return;
    
    [pubnub
     performSelector: @selector(subscribe:)
     withObject: [NSDictionary
                  dictionaryWithObjectsAndKeys:
                  channel,  @"channel",
                  delegate, @"delegate",
                  @"1",     @"timetoken",
                  nil]
     afterDelay: 1.0
     ];
}
@end

@implementation PresenceDelegate
-(void) callback:(NSURLConnection *)connection withResponce:(id)response {
    NSArray* response_data = [parser objectWithString: response];
    if (![pubnub subscribed: channel]) return;
    [pubnub removeConnection:channel];
    [pubnub
     performSelector: @selector(presence:)
     withObject: [NSDictionary
                  dictionaryWithObjectsAndKeys:
                  channel,                         @"channel",
                  delegate,                        @"delegate",
                  [response_data objectAtIndex:1], @"timetoken",
                  nil]
     ];
    
    id message;
    NSEnumerator* messages = [[response_data objectAtIndex:0]
                              objectEnumerator
                              ];
    
    while ((message = [messages nextObject])) {
        [delegate callback:connection withResponce:message ];
    }
    
}

-(void) fail:(NSURLConnection *)connection withResponce: (id) response {
    if (![pubnub subscribed: channel]) return;
      [pubnub removeConnection:channel];
    [pubnub
     performSelector: @selector(presence:)
     withObject: [NSDictionary
                  dictionaryWithObjectsAndKeys:
                  channel,  @"channel",
                  delegate, @"delegate",
                  @"1",     @"timetoken", 
                  nil]
     afterDelay: 1.0
     ];
}
@end

@implementation TimeDelegate
-(void) callback:(NSURLConnection *)connection withResponce:(id) response {
    [delegate callback:connection withResponce: [[parser objectWithString: response] objectAtIndex:0]];
}
@end

