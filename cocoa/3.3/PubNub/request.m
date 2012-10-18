#import "request.h"
#import "pubnub.h"
#import "JSON.h"

@implementation Request
@synthesize connection,channel,command,delegate;

-(id)
    scheme:   (NSString*) scheme
    host:     (NSString*) host
    path:     (NSString*) path
    callback: (Response*) callback
    channel:  (NSString*) _channel
    pubnub:   (Pubnub *)_pubnub
    command:  (Command)_command
{
  
    delegate = callback;
    pubnub=_pubnub;
    command =_command;
    NSURL *url = [NSURL
        URLWithString: [NSString
            stringWithFormat: @"%@://%@%@",
            scheme,
            host,
            path]];

    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:  url 
        cachePolicy:     NSURLRequestReloadIgnoringCacheData 
        timeoutInterval: 310
    ];
    [request setValue:@"3.3" forHTTPHeaderField:@"V"];
    [request setValue:@"Cocoa" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
    connection = [[NSURLConnection alloc]
        initWithRequest:  request
        delegate:         self
    ];
    channel = _channel;
    return  self;
}

-(void)
    connection:     (NSURLConnection*) connection
    didReceiveData: (NSData*) data
{
    if (response == nil) {
        response = [[NSMutableData alloc] initWithData:data];
    } else {
        [response appendData:data];
    }
}

-(void)
    connectionDidFinishLoading: (NSURLConnection *) _connection
{
        //[delegate callback:self withResponce: response];
    NSError* error = nil;
    
    if ([NSJSONSerialization class]) {
        id result= [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        if (error != nil) result = nil;
        [pubnub didCompleteWithRequest:self WithResponse:result isfail:NO ];
    }else
    {
            // NSLog(@"NSJSONSerialization not support..");
        [pubnub didCompleteWithRequest:self WithResponse:JSONParseData(response) isfail:NO ]; 
    }
    
}

-(void)
    connection:       (NSURLConnection*) _connection
    didFailWithError: (NSError *) error
{
    if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorNotConnectedToInternet)) {
        NSLog(@"PubNub request failed due to missing Internet connection");
        switch ([self command]) {
            case kCommand_SendMessage:
                [pubnub didCompleteWithRequest:self WithResponse:[NSArray arrayWithObjects:@"0",@"PubNub request failed due to missing Internet connection" ,@"0",  nil] isfail:YES];
                break;
                
            default:
                [pubnub didCompleteWithRequest:self WithResponse:nil isfail:YES];
                break;
        }
        
    } else {
        switch ([self command]) {
            case kCommand_SendMessage:
                [pubnub didCompleteWithRequest:self WithResponse:[NSArray arrayWithObjects:@"0", [NSString stringWithFormat:@"PubNub request failed with error: %@", error ] ,@"0",  nil] isfail:YES];
                break;
                
            default:
                [pubnub didCompleteWithRequest:self WithResponse:nil isfail:YES ];
                break;
        }
        NSLog(@"PubNub request failed with error: %@", error);
    }
    
}
@end

@implementation Response
-(Response*)
    finished: (id)      callback
    pubnub:   (Pubnub*) pubnub_o
{
        // self     = [super init];
    delegate = callback;
    pubnub   = pubnub_o;
    return self;
}
-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o
{
        //  self     = [super init];
    delegate = callback;
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
        // self     = [super init];
    delegate = callback;
    pubnub   = pubnub_o;
    channel  = channel_o;
    message  = message_o;
    return self;
}

-(Response*)
pubnub:   (Pubnub*)   pubnub_o
channel:  (NSString*) channel_o
{
        // self     = [super init];
    delegate = nil;
    pubnub   = pubnub_o;
    channel  = channel_o;
    return self;
}

-(Response*)
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o
    message:  (id)message_o
{
        // self     = [super init];
    delegate = nil;
    pubnub   = pubnub_o;
    channel  = channel_o;
    message  = message_o;
    return self;
}
-(void) callback:(NSURLConnection*) connection withResponce: (id) response  {
      NSError* error = nil;
    if ([NSJSONSerialization class]) {
        id result= [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        if (error != nil) result = nil;
        [delegate callback:connection withResponce:result];
    }else
    {
            //  NSLog(@"NSJSONSerialization not support.");
        [delegate callback:connection withResponce:JSONParseData(response)];
        
    }
}
-(void) fail: (NSURLConnection*) connection withResponce: (id) response  {
    [delegate fail: connection withResponce: response];
}
@end
