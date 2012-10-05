#import "request.h"

@implementation Request
@synthesize connection,channel;

-(id)
    scheme:   (NSString*) scheme
    host:     (NSString*) host
    path:     (NSString*) path
    callback: (Response*) callback
    channel:  (NSString*) _channel
{
    pool     = [[NSAutoreleasePool alloc] init];
    delegate = callback;

    NSURL *url = [NSURL
        URLWithString: [NSString
            stringWithFormat: @"%@://%@%@",
            scheme,
            host,
            path
        ]
    ];

    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:  url 
        cachePolicy:     NSURLRequestReloadIgnoringCacheData 
        timeoutInterval: 310
    ];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
    connection = [[NSURLConnection alloc]
        initWithRequest:  request
        delegate:         self
    ];
    channel = _channel;
    [connection autorelease];
    return  self;
}

-(void)
    connection:     (NSURLConnection*) connection
    didReceiveData: (NSData*) data
{
    response = [[NSString alloc]
        initWithBytes: [data bytes]
        length: [data length]
        encoding: NSASCIIStringEncoding
    ];
}

-(void)
    connectionDidFinishLoading: (NSURLConnection *) _connection
{
    [delegate callback:_connection withResponce: response];
}

-(void)
    connection:       (NSURLConnection*) _connection
    didFailWithError: (NSError *) error
{
    [delegate fail:_connection withResponce: error];
}
@end

@implementation Response
-(Response*)
    finished: (id)      callback
    pubnub:   (Pubnub*) pubnub_o
{
    self     = [super init];
    delegate = callback;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    return self;
}
-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o
{
    self     = [super init];
    delegate = callback;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    channel  = channel_o;
    return self;
}

-(Response*)
finished: (id)        callback
pubnub:   (Pubnub*)   pubnub_o
channel:  (NSString*) channel_o
message:  (id)message_o
{
    self     = [super init];
    delegate = callback;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    channel  = channel_o;
    message  = message_o;
    return self;
}

-(Response*)
pubnub:   (Pubnub*)   pubnub_o
channel:  (NSString*) channel_o
{
    self     = [super init];
    delegate = nil;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    channel  = channel_o;
    return self;
}
-(Response*)
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o
    message:  (id)message_o
{
    self     = [super init];
    delegate = nil;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    channel  = channel_o;
    message  = message_o;
    return self;
}
-(void) callback:(NSURLConnection*) connection withResponce: (id) response  {
    [delegate callback:connection withResponce: [parser objectWithString: response]];
}
-(void) fail: (NSURLConnection*) connection withResponce: (id) response  {
    [delegate fail: connection withResponce: response];
}
@end
