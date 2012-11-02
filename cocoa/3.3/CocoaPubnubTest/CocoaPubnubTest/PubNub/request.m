#import "request.h"
#import "pubnub.h"
#import "JSON.h"

#define NATIVE_JSON_AVAILABLE __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000 || __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070


@implementation Request
@synthesize connection,channel,command,delegate,timetoken;

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
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
  
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
#if NATIVE_JSON_AVAILABLE
    {
         NSError* error = nil;
        id result= [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        if (error != nil) result = nil;
        [pubnub didCompleteWithRequest:self WithResponse:result isfail:NO ];
    }
#else
    {
        [pubnub didCompleteWithRequest:self WithResponse:JSONParseData(response) isfail:NO ]; 
    }
#endif

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
                    //[pubnub didCompleteWithRequest:self WithResponse:nil isfail:YES ];
                if([Pubnub isApplicationActive]){
                    [pubnub didCompleteWithRequest:self WithResponse:nil isfail:YES];
                    NSLog(@"PubNub request failed with error: %@", error);
                }else
                {
                    [pubnub performSelector: @selector(_resubscribe:)
                                 withObject: [NSDictionary
                                              dictionaryWithObjectsAndKeys:
                                              channel,  @"channel",
                                              delegate, @"delegate",
                                              timetoken,     @"timetoken",
                                              nil]
                                 afterDelay: 1.0
                     ];
                    [Pubnub setApplicationActive:YES];
                }
                
                break;
        }
            // NSLog(@"PubNub request failed with error: %@", error);
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
    message  = [[NSString alloc]initWithFormat:@"%@",message_o ];
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
    message  =  [[NSString alloc]initWithFormat:@"%@",message_o ];
    return self;
}
-(void) callback:(NSURLConnection*) connection withResponce: (id) response  {
      
#if NATIVE_JSON_AVAILABLE
    {
         NSError* error = nil;
        id result= [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        if (error != nil) result = nil;
        [delegate callback:connection withResponce:result];
    }
#else
    {
            //  NSLog(@"NSJSONSerialization not support.");
        [delegate callback:connection withResponce:JSONParseData(response)];
        
    }
#endif   
}
-(void) fail: (NSURLConnection*) connection withResponce: (id) response  {
    [delegate fail: connection withResponce: response];
}

-(void) connectToChannel:(NSString *)_channel
{
    if ([delegate respondsToSelector:@selector(connectToChannel:)]) {
        [delegate connectToChannel:_channel]; 
    }
}

-(void)reconnectToChannel:(NSString *)_channel
{
    if ([delegate respondsToSelector:@selector(reconnectToChannel:)]) {  
        [delegate reconnectToChannel:_channel]; 
    }
}

-(void)disconnectFromChannel:(NSString *)_channel
{
    if ([delegate respondsToSelector:@selector(reconnectToChannel:)])
    {
        [delegate reconnectToChannel:_channel];  
    }
}

@end

@implementation ChannelStatus
@synthesize connected,channel,first;
@end

