#import "pubnub.h"

@interface NSString (Extensions)
- (NSString*) urlEscapedString;  // Uses UTF-8 encoding and also escapes characters that can confuse the parameter 
@end

@implementation NSString (Extensions)
- (NSString*) urlEscapedString {
    return (__bridge_transfer id)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, CFSTR(":@/?&=+"),kCFStringEncodingUTF8) ;
}
@end

@implementation Pubnub

-(Pubnub*)
    publishKey:   (NSString*) pub_key
    subscribeKey: (NSString*) sub_key
    secretKey:    (NSString*) sec_key
    sslOn:        (BOOL)      ssl_on
    origin:       (NSString*) origin
{
    publish_key   = pub_key;
    subscribe_key = sub_key;
    secret_key    = sec_key;
    scheme        = ssl_on ? @"https" : @"http";
    host          = origin;
    subscriptions = [[NSMutableDictionary alloc] init];
    current_uuid  = [Pubnub uuid];
    _connections= [[NSMutableDictionary alloc] init];
    return self;
}

+(NSString*) md5: (NSString*) stringToHash {
    const char *src = [stringToHash UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(src, (unsigned int)strlen(src), result);
    return [[NSString alloc]initWithData:[NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH] encoding:NSUTF8StringEncoding ];
    
}

+ (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

/**
 Publish
 Send a message to a channel.
 * /publish/pub-key/sub-key/signature/channel/callback/"msg"
 */

-(void)
    publish:  (NSString*) channel
    message:  (id)        message
    delegate: (id)        delegate
{
    NSString* message_string =[Pubnub JSONToString:message];
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
            [channel urlEscapedString],
            [message_string urlEscapedString]
        ]
        callback: delegate
        channel:  channel
        pubnub:self
     command:kCommand_SendMessage
    ];
}

/**
 subscribed
 
 Check the channel allready subscribed or not.
 */
-(BOOL) subscribed: (NSString*) channel {
    if ([subscriptions objectForKey: channel]) return YES;
    return NO;
}

/**
 * Subscribe
 *
 * Listen for a message on a channel 
 *
 * @param NSDictionary containt channel name,timetoken and delegate.
 * 
 */
// * /subscribe/sub-key/channel/callback/timetoken
-(void) subscribe: (NSDictionary*) args {
    NSString* channel = [args objectForKey:@"channel"];
   Request * request=  [[Request alloc]
        scheme: scheme
        host:   host
        path:   [NSString
        stringWithFormat: @"/subscribe/%@/%@/0/%@/?uuid=%@",
        subscribe_key,
        [channel urlEscapedString],
        [args objectForKey:@"timetoken"],
        current_uuid
        ]
     
        callback: [args objectForKey:@"delegate"]
        channel:  channel
        pubnub:self
        command:kCommand_ReceiveMessage
    ];
    
    [_connections setObject:request forKey:channel];
}

/**
 * Subscribe
 *
 * Listen for a message on a channel
 *
 * @param NSString channel name.
 * @param id delegate
 */
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
/**
 * Detaile dHistory
 *
 * Load Previously Published Messages in Detail
 *
 * @param NSDictionary contains 
                        channel',
                        delegate and 
                        optional: 'start', 'end', 'reverse', 'count'
 *          
 */
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
              [channel urlEscapedString],
              [parameters description]
              ]
     callback: delegate
     channel:channel
     pubnub:self
     command:kCommand_FetchDetailHistory
     ];
}

/**
 * Here Now
 *
 * Load current occupancy from a channel.
 *
 * @param channel and delegate
 *
 */
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
              [channel urlEscapedString]
              ]
     callback:delegate
      channel:  channel
       pubnub:  self
      command:  kCommand_Here_Now
     ];
}

/**
 * Unsubscribe
 *
 * Stop listen for a message on a channel.
 *
 * @param channel
 *
 */
-(void) unsubscribe: (NSString*) channel {
    Request *_req = [_connections objectForKey:channel];
    
    [_req.connection cancel];
    [_connections removeObjectForKey:channel];
    [subscriptions removeObjectForKey:channel];
    NSLog(@"Unsubscribe successfully.");  
}

-(void) removeConnection: (NSString*) channel{
     [_connections removeObjectForKey:channel];
}

/**
 * History
 *
 * Load history from a channel
 *
 * @param NSString channel name.
 * @param int limit history count response
 * @param id delegate
 */
// * /history/sub-key/channel/callback/limit
-(void)
    history:  (NSString*) channel
    limit:    (int)       limit		
    delegate: (id)        delegate
{
    if (limit > 100) limit = 100;

    [[Request alloc]
        scheme  : scheme
        host    : host
        path:     [NSString
                  stringWithFormat: @"/history/%@/%@/0/%i",
                  subscribe_key,
                  [channel urlEscapedString],
                  limit]
        callback: delegate
         channel: channel
          pubnub: self
         command: kCommand_FetchHistory
    ];
}

/**
 * Time
 *
 * Timestamp from PubNub Cloud
 *
 * @param id delegate
 */
-(void) time: (id) delegate {
    [[Request alloc]
        scheme  :scheme
        host    :host
        path    :@"/time/0"
        callback:delegate		
        channel :nil
        pubnub  :self
        command :kCommand_GetTime
    ];
}	

/**
 * Presence feature
 *
 * Listen for a presence message on a channel (BLOCKING)
 *
 * @param NSString channel name. (+"pnpres")
 * @param id delegate
 */
-(void)
presence: (NSString*) channel
delegate:  (id)       delegate
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
     scheme  : scheme
     host    : host
     path    : [NSString
              stringWithFormat: @"/subscribe/%@/%@/0/%@/?uuid=%@",
              subscribe_key,
              [channel urlEscapedString],
              [args objectForKey:@"timetoken"],
              current_uuid
              ]
     callback: [args objectForKey:@"delegate"]
     channel :channel
     pubnub  :self
     command :kCommand_Presence
     ];
}

+(NSString*)JSONToString:(id)object
{
    NSString * jsonString= nil;
    if ([NSJSONSerialization class]) {
        if ([object isKindOfClass:[NSString class]]) {
            object = [NSString stringWithFormat:@"\"%@\"", object];
            
            return object;
        } else {
            NSError* error = nil;
            id result = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
            if (error != nil) return nil;
            jsonString =[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            
        }
    }else{
        NSLog(@"NSJSONSerialization not support.");
    }
    return jsonString;
}

+(id)StringToJSON:(id)object
{
    NSError* error = nil;
    if ([NSJSONSerialization class]) {
        id result= [NSJSONSerialization JSONObjectWithData:object options:kNilOptions error:&error];
        if (error != nil) result = nil;
        return result;
    }else
    {
        NSLog(@"NSJSONSerialization not support.");
        return nil;
    }
}

- (void)didCompleteWithRequest:(Request*)request WithResponse:(id)response isfail:(BOOL) isFail {
   
    switch (request.command) {
         case kCommand_SendMessage:
             [self handleCommandSendMessageForRequest:request response:response isfail:isFail];
             break;
             
         case kCommand_ReceiveMessage:
             [self handleCommandReceiveMessageForRequest:request response:response isfail: isFail];
             break;
             
         case kCommand_FetchDetailHistory:
             [self handleCommandFetchDetailHistoryForRequest:request response:response isfail: isFail];
             break;
             
         case kCommand_FetchHistory:
             [self handleCommandFetchHistoryForRequest:request response:response isfail: isFail];
             break;
             
         case kCommand_GetTime:
             [self handleCommandGetTimeForRequest:request response:response isfail: isFail];
             break;
             
         case kCommand_Here_Now: 
             [self handleCommandGetHereNowForRequest:request response:response isfail: isFail];
             break;
        case kCommand_Presence:
            [self handleCommandPresenceNowForRequest:request response:response isfail: isFail];
            break;
         default:
             NSLog(@"ERROR::didCompleteWithResponse Command Not Set..");
             
        }
}

#pragma mark - command handlers for -connection:didCompleteWithResponse:

- (void)handleCommandSendMessageForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
    if(!isfail)
        [request.delegate callback:request withResponce:response ];
    else
        [request.delegate fail:request withResponce:nil ];
}

- (void)handleCommandReceiveMessageForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
   if(!isfail)
   {
       NSArray* response_data=(NSArray*)response;
       if (![self subscribed: request.channel]) return;
       
       [self
        performSelector: @selector(subscribe:)
        withObject: [NSDictionary
                     dictionaryWithObjectsAndKeys:
                     request.channel,                 @"channel",
                     request.delegate,                @"delegate",
                     [response_data objectAtIndex:1], @"timetoken",
                     nil]
        ];
       NSEnumerator* messages = [[response_data objectAtIndex:0]
                                 objectEnumerator
                                 ];
       id nextMessage;
       while ((nextMessage = [messages nextObject])) {
           [request.delegate callback:request withResponce:nextMessage ];
       }
   }else
   {
       if (![self subscribed: request.channel]) return;
       [self
        performSelector: @selector(subscribe:)
        withObject: [NSDictionary
                     dictionaryWithObjectsAndKeys:
                     request.channel,  @"channel",
                     request.delegate, @"delegate",
                     @"1",     @"timetoken",
                     nil]
        afterDelay: 1.0
        ];
   }
}

- (void)handleCommandFetchDetailHistoryForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
    if(!isfail)
        [request.delegate callback:request withResponce:response ];
    else
        [request.delegate fail:request withResponce:nil ];
}

- (void)handleCommandPresenceNowForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
   if(!isfail)
   {
       NSArray* response_data=(NSArray* )response;
       
       if (![self subscribed: request.channel]) return;
       [self removeConnection:request.channel];
       [self
        performSelector: @selector(presence:)
        withObject: [NSDictionary
                     dictionaryWithObjectsAndKeys:
                     request.channel,                 @"channel",
                     request.delegate,                @"delegate",
                     [response_data objectAtIndex:1], @"timetoken",
                     nil]
        ];
       
       id nextMessage;
       NSEnumerator* messages = [[response_data objectAtIndex:0]
                                 objectEnumerator
                                 ];
       
       while ((nextMessage = [messages nextObject])) {
           [request.delegate callback:request withResponce:nextMessage ];
       }
   }else
   {
       if (![self subscribed: request.channel]) return;
       [self removeConnection:request.channel];
       [self
        performSelector: @selector(presence:)
        withObject: [NSDictionary
                     dictionaryWithObjectsAndKeys:
                     request.channel,  @"channel",
                     request.delegate, @"delegate",
                     @"1",     @"timetoken",
                     nil]
        afterDelay: 1.0
        ];
   }
}

- (void)handleCommandFetchHistoryForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
    [request.delegate callback:request withResponce:response ];
}

- (void)handleCommandGetTimeForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
    if (!isfail) {
        NSArray* response_data=(NSArray* )response;
        [request.delegate callback:request withResponce: [response_data objectAtIndex:0]];
    } else {
        [request.delegate callback:request withResponce: @"0"];
    }
}

- (void)handleCommandGetHereNowForRequest:(Request *)request response:(id)response isfail:(BOOL) isfail
{
    if(!isfail)
        [request.delegate callback:request withResponce:response ];
    else
        [request.delegate fail:request withResponce:nil ];
}

@end

