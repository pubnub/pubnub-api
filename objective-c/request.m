#import "request.h"

@implementation Request
-(void)
    scheme:   (NSString*) scheme
    host:     (NSString*) host
    path:     (NSString*) path
    callback: (Response*) callback;
{
    pool     = [[NSAutoreleasePool alloc] init];
    deligate = callback;

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
        timeoutInterval: 200
    ];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
    NSURLConnection *connection = [[NSURLConnection alloc]
        initWithRequest:  request
        delegate:         self
    ];

    [connection autorelease];
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
    connectionDidFinishLoading: (NSURLConnection *) connection
{
    [deligate callback: response];
}

-(void)
    connection:       (NSURLConnection*) connection
    didFailWithError: (NSError *) error
{
    [deligate fail: response];
}
@end

@implementation Response
-(Response*)
    finished: (id)      callback
    pubnub:   (Pubnub*) pubnub_o
{
    self     = [super init];
    deligate = callback;
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
    deligate = callback;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    channel  = channel_o;
    return self;
}
-(Response*)
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o
{
    self     = [super init];
    deligate = nil;
    parser   = [SBJsonParser new];
    pubnub   = pubnub_o;
    channel  = channel_o;
    return self;
}
-(void) callback: (id) response {
    [deligate callback: [parser objectWithString: response]];
}
-(void) fail: (id) response {
    [deligate fail: response];
}
@end
