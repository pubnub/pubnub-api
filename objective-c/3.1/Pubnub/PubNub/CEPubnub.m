    // Copyright 2011 Cooliris, Inc.
    //
    // Licensed under the Apache License, Version 2.0 (the "License");
    // you may not use this file except in compliance with the License.
    // You may obtain a copy of the License at
    //
    //     http://www.apache.org/licenses/LICENSE-2.0
    //
    // Unless required by applicable law or agreed to in writing, software
    // distributed under the License is distributed on an "AS IS" BASIS,
    // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    // See the License for the specific language governing permissions and
    // limitations under the License.

#import "CEPubnub.h"
#import "JSON.h"
#import "Common.h"

#define kDefaultOrigin @"pubsub.pubnub.com"
#define kMaxHistorySize 100  // From documentation
#define kConnectionTimeOut 310.0  // From https://github.com/jazzychad/CEPubnub/blob/master/CEPubnub/CEPubnubRequest.m
#define kMinRetryInterval 5.0
#define kInitialTimeToken @"0"

typedef enum {
    kCommand_Undefined = 0,
    kCommand_SendMessage,
    kCommand_ReceiveMessage,
    kCommand_FetchHistory,
    kCommand_GetTime
} Command;

@interface PubNubConnection : NSURLConnection {
@private
    CEPubnub * _pubNub;
    Command _command;
    NSString* _channel;
    
    NSHTTPURLResponse* _response;
    NSMutableData* _data;
}
@property(nonatomic, readonly) Command command;
@property(nonatomic, readonly) NSString* channel;
@property(nonatomic, readonly) NSData* data;
- (id) initWithPubNub:(CEPubnub*)pubNub url:(NSURL*)url command:(Command)command channel:(NSString*)channel;
@end

@interface CEPubnub ()
- (void) connection:(PubNubConnection*)connection didCompleteWithResponse:(id)response;
@end

@implementation ChannelStatus
@synthesize connected,channel,first;
@end

@implementation PubNubConnection

@synthesize command=_command, channel=_channel, data=_data;

- (id) initWithPubNub:(CEPubnub*)pubNub url:(NSURL*)url command:(Command)command channel:(NSString*)channel {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:kConnectionTimeOut];
    [request setValue:@"V" forHTTPHeaderField:@"3.1"];
    [request setValue:@"User-Agent" forHTTPHeaderField:@"Obj-C-iOS"];
    [request setValue:@"Accept" forHTTPHeaderField:@"gzip"];
    
        //   [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    if ((self = [super initWithRequest:request delegate:self])) {
        _command = command;
        _pubNub = pubNub;
        _channel = [channel copy];
    }
    
    return self;
}



- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
        // DCHECK(_response == nil);
    _response = (NSHTTPURLResponse*)[response copy];
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    if (_data == nil) {
        _data = [[NSMutableData alloc] initWithData:data];
    } else {
        [_data appendData:data];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
    if (_response.statusCode == 200) {
            //  NSString* contente = [[_response allHeaderFields] objectForKey:@"Content-Encoding"];
            //  NSLog(@"PubNub request returned Content-Encoding : %@", contente);
        NSString* contentType = [[_response allHeaderFields] objectForKey:@"Content-Type"];
        if ([contentType hasPrefix:@"text/javascript"] && [contentType containsString:@"UTF-8"]) {  // Should be [text/javascript; charset="UTF-8"] but is sometimes different on 3G
            [_pubNub connection:self didCompleteWithResponse:JSONParseData(_data)];
                //  NSLog(@"PubNub request returned unexpected content type: %@", contentType);
        } else {
            NSLog(@"PubNub request returned unexpected content type: %@", contentType);
            switch ([self command]) {
                case kCommand_SendMessage:
                    [_pubNub connection:self didCompleteWithResponse:[NSArray arrayWithObjects:@"0", [NSString stringWithFormat:@"PubNub request returned unexpected content type: %@", contentType ] ,@"0",  nil]];
                    break;
                    
                default:
                    [_pubNub connection:self didCompleteWithResponse:nil];
                    break;
            }
            
        }
    } else {
        NSLog(@"PubNub request failed with HTTP status code %i", _response.statusCode);
        switch ([self command]) {
            case kCommand_SendMessage:
                [_pubNub connection:self didCompleteWithResponse:[NSArray arrayWithObjects:@"0", [NSString stringWithFormat:@"PubNub request failed with HTTP status code %i", _response.statusCode ] ,@"0",  nil]];
                break;
                
            default:
                [_pubNub connection:self didCompleteWithResponse:nil];
                break;
        }
        
    }
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorNotConnectedToInternet)) {
        NSLog(@"PubNub request failed due to missing Internet connection");
        switch ([self command]) {
            case kCommand_SendMessage:
                [_pubNub connection:self didCompleteWithResponse:[NSArray arrayWithObjects:@"0",@"PubNub request failed due to missing Internet connection" ,@"0",  nil]];
                break;
                
            default:
                [_pubNub connection:self didCompleteWithResponse:nil];
                break;
        }
        
    } else {
        switch ([self command]) {
            case kCommand_SendMessage:
                [_pubNub connection:self didCompleteWithResponse:[NSArray arrayWithObjects:@"0", [NSString stringWithFormat:@"PubNub request failed with error: %@", error ] ,@"0",  nil]];
                break;
                
            default:
                [_pubNub connection:self didCompleteWithResponse:nil];
                break;
        }
        NSLog(@"PubNub request failed with error: %@", error);
    }
}

@end

@implementation CEPubnub

@synthesize delegate=_delegate;

- (CEPubnub*) initWithSubscribeKey:(NSString*)subscribeKey useSSL:(BOOL)useSSL {
    return [self initWithPublishKey:nil subscribeKey:subscribeKey secretKey:nil useSSL:useSSL cipherKey:nil origin:kDefaultOrigin];
}

- (CEPubnub*) initWithPublishKey:(NSString*)publishKey
                    subscribeKey:(NSString*)subscribeKey
                       secretKey:(NSString*)secretKey
                          useSSL:(BOOL)useSSL {
    return [self initWithPublishKey:publishKey subscribeKey:subscribeKey secretKey:secretKey useSSL:useSSL cipherKey:nil origin:kDefaultOrigin];
}

- (CEPubnub*) initWithPublishKey:(NSString*)publishKey
                    subscribeKey:(NSString*)subscribeKey
                       secretKey:(NSString*)secretKey
                          useSSL:(BOOL)useSSL
                       cipherKey:(NSString*)cipherKey  
                          origin:(NSString*)origin {
    if ((self = [super init])) {
        _publishKey = [publishKey copy];
        _subscribeKey = [subscribeKey copy];
        _secretKey = [secretKey copy];
        _host = [[NSString alloc] initWithFormat:@"%@://%@", useSSL ? @"https" : @"http", origin];
        _cipherKey=[cipherKey copy];
        _connections = [[NSMutableSet alloc] init];
    }
    return self;
}

- (CEPubnub*) initWithPublishKey:(NSString*)publishKey
                    subscribeKey:(NSString*)subscribeKey
                       secretKey:(NSString*)secretKey
                       cipherKey:(NSString*)cipherKey
                          useSSL:(BOOL)useSSL{
    return [self initWithPublishKey:publishKey subscribeKey:subscribeKey secretKey:secretKey useSSL:useSSL cipherKey:cipherKey origin:kDefaultOrigin];
}

- (void) dealloc {
    for (PubNubConnection* connection in _connections) {
        [connection cancel];
    }
    
}

-(NSDictionary*) getEncryptedDictionary:(NSDictionary*)message
{
    if(_cipherKey != nil)
    {
        NSMutableDictionary* msg = [NSMutableDictionary dictionaryWithCapacity: message.count];
        NSDictionary* disc = (NSDictionary*) message;
        for (NSString* key in [disc allKeys]) {
            NSString* val = (NSString*)[disc objectForKey:key];
            NSString * dec = [CommonFunction AES128EncryptWithKey: _cipherKey Data:val];
            [msg setObject: dec forKey:key];
        }
        
        return msg;
    }
    return [NSMutableDictionary dictionaryWithDictionary: message];
}

-(NSString*) getEncryptedString:(NSString*)disc
{
    NSString * returnval;
    if(_cipherKey != nil)
    {
        returnval=  [CommonFunction AES128EncryptWithKey:_cipherKey Data:disc];
    }
    else {
        returnval=disc ;
    }
    return returnval;
}

-(NSArray*) getEncryptedArray:(NSArray*)array
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity: 10];
    for (int i=0; i<array.count; i++) {
        id object= [array objectAtIndex:i];
        if ([object isKindOfClass:[NSString class]]) {
            [messages addObject:[self getEncryptedString:(NSString *)object]];
            
        } else if ([object isKindOfClass:[NSArray class]]) {
            [messages addObject:[self getEncryptedArray:(NSArray *)object ]]; 
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            [messages addObject:[self getEncryptedDictionary:(NSDictionary *)object]];
        }
    }
    return messages;
}

- (void) publish:(NSString * )message onChannel:(NSString *) channel{
    NSDictionary *disc=   [NSDictionary dictionaryWithObjectsAndKeys:channel,@"channel",message,@"message", nil];
    [self publish:disc];
}

- (void) publish:(NSDictionary * )arg1{
    NSString * channel = [arg1 objectForKey: @"channel"];
    id message = [arg1 objectForKey: @"message"];
    if (!channel) {
        NSLog(@"ERROR::Channel name not found.");
        return;
    }
    
    if (!message) {
        NSLog(@"ERROR::Message not found.");
        return;
    }
    
    id msg = nil;
    if ([message isKindOfClass:[NSString class]]) {
        msg = [self getEncryptedString:(NSString*) message];
    } else if ([message isKindOfClass:[NSArray class]]) {
        msg = [self getEncryptedArray:(NSArray*) message];
    } else if ([message isKindOfClass:[NSDictionary class]]) {
        msg = [self getEncryptedDictionary:(NSDictionary*) message];
    }
    
    NSString* json = JSONWriteString(msg);
    NSString* signature;
    if (_secretKey) {
        signature =[CommonFunction HMAC_SHA256withKey:[NSString stringWithFormat:@"%@",_secretKey] Input:[NSString stringWithFormat:@"%@/%@/%@/%@/%@", _publishKey, _subscribeKey, _secretKey, channel, json] ];
    } else {
        signature = @"0";
    }
    NSString* url = [NSString stringWithFormat:@"%@/publish/%@/%@/%@/%@/0/%@", _host, _publishKey, _subscribeKey, signature,
                     [channel urlEscapedString], [json urlEscapedString]];
    
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_SendMessage
                                                                    channel:channel];
    [_connections addObject:connection];
}

- (void) _resubscribeToChannel:(NSString*)channel timeToken:(NSString*)timeToken {
    
    NSString* url = [NSString stringWithFormat:@"%@/subscribe/%@/%@/0/%@", _host, _subscribeKey, [channel urlEscapedString], timeToken];
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_ReceiveMessage
                                                                    channel:channel];
    [_connections addObject:connection];
    
}

- (void) _resubscribeToChannel:(NSString*)channel {
        // Ensure Single Connection
    if (_subscriptions && [_subscriptions count] > 0) {
        
        BOOL channel_exist = NO;
        for (ChannelStatus* it in [_subscriptions copy]) {
            if ([it.channel isEqualToString:channel])
            {
                channel_exist = YES;
                break;
            }
        }
        
        if (!channel_exist) {
            ChannelStatus *cs = [[ChannelStatus alloc] init] ;
            cs.channel = channel;
            cs.connected = YES;
            [_subscriptions addObject:cs];
        } else {
                // error_cb.execute("Already Connected");
                //return;
        }
    } else {
            // New Channel
        ChannelStatus *cs = [[ChannelStatus alloc] init] ;
        cs.channel = channel;
        cs.connected = YES;
        _subscriptions = [[NSMutableSet alloc] init];
        [_subscriptions addObject:cs];
    }
    
    [self _resubscribeToChannel:channel timeToken:kInitialTimeToken];
}

- (void) subscribe:(NSString*)channel {
    if (![self isSubscribedToChannel:channel]) {
        [self _resubscribeToChannel:channel];
        NSLog(@"Did subscribe to PubNub channel \"%@\"", channel);
    }
}

- (void) unsubscribeFromChannel:(NSString*)channel {
    for (PubNubConnection* connection in [_connections copy]) {
        if ((connection.command == kCommand_ReceiveMessage) && (!channel || [connection.channel isEqualToString:channel])) {
            NSLog(@"Did unsubscribe from PubNub channel \"%@\"", connection.channel);
            [connection cancel];
            [_connections removeObject:connection];
            for (ChannelStatus* it in [_subscriptions copy]) {
                if ([it.channel isEqualToString:connection.channel])
                {
                    it.connected=false;
                    it.first=false;
                    if ([_delegate respondsToSelector:@selector(pubnub:DisconnectToChannel:)]) {
                        [_delegate pubnub:self DisconnectToChannel:connection.channel];
                    }
                    [_subscriptions removeObject:it];
                    break;
                }
            }
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL) isSubscribedToChannel:(NSString*)channel {
    for (PubNubConnection* connection in _connections) {
        if ((connection.command == kCommand_ReceiveMessage) && [connection.channel isEqualToString:channel]) {
            if ([_delegate respondsToSelector:@selector(pubnub:subscriptionDidFailWithResponse:onChannel:)]) {
                [_delegate pubnub:self subscriptionDidFailWithResponse:@"Already Connected" onChannel:channel];
            }           
            return YES;
        }
    }
    for (ChannelStatus* it in [_subscriptions copy]) {
        if ([it.channel isEqualToString:channel])
        {                        
            it.connected=false;
            it.first=false;
        }
    }    
    return NO;
}

- (void) unsubscribeFromAllChannels {
    [self unsubscribeFromChannel:nil];
}

- (void) fetchHistory:(NSUInteger)limit forChannel:(NSString*)channel {
    NSNumber * aWrappedInt = [NSNumber numberWithInteger:limit]; 
    NSDictionary* disc=  [NSDictionary dictionaryWithObjectsAndKeys: aWrappedInt,@"limit", channel,@"channel",nil];
    [self fetchHistory:disc];
}

- (void) fetchHistory:(NSDictionary * )arg1 {
    int limit;
    NSString* channel;
    if (![arg1 objectForKey:@"limit"]) 
    {
        NSLog(@"ERROR::limit not found.");
        return;
        
    }else 
    {
        limit=[[arg1 objectForKey:@"limit"] intValue];
    }
    
    if (![arg1 objectForKey:@"channel"]) 
    {
        NSLog(@"ERROR::Channel name not found.");
        return;
    }else 
    {
        channel=[arg1 objectForKey:@"channel"];
    }
    
    if (limit > kMaxHistorySize) {
        NSLog(@"PubNub history too large: %i", limit);
    }
    NSString* url = [NSString stringWithFormat:@"%@/history/%@/%@/0/%i", _host, _subscribeKey, [channel urlEscapedString], limit];
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_FetchHistory
                                                                    channel:channel];
    [_connections addObject:connection];
}

- (void) getTime {
    NSString* url = [NSString stringWithFormat:@"%@/time/0", _host];
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_GetTime
                                                                    channel:nil];
    [_connections addObject:connection];
}

NSDecimalNumber* time_token = 0;

- (void) getTime1	 {
    NSString* url = [NSString stringWithFormat:@"%@/time/0", _host]; 
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:[[NSOperationQueue alloc] init] 
     completionHandler:^(NSURLResponse *response2,
                         NSData *data,
                         NSError *error) 
     {
         
         if ([data length] >0 && error == nil)
         {
             NSArray* resp=    (NSArray *)JSONParseData(data);
             if ([resp isKindOfClass:[NSArray class]]) {
                 time_token = [resp objectAtIndex:0];
             }
         }
         else if ([data length] == 0 && error == nil)
         {
             time_token=0;
         }
         else if (error != nil){
             time_token=0;
         }
     }];
}

+ (NSString *) getUUID
{
    return [CommonFunction generateUuidString];
}

-(NSDictionary*) getDecryptedDictionary:(NSDictionary*)message
{
    if(_cipherKey != nil)
    {
        NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithCapacity: message.count];
        for (NSString* key in [message allKeys]) {
            NSString* val = (NSString*) [message objectForKey: key];
            NSString* dec = [CommonFunction AES128DecryptWithKey: _cipherKey Data: val];
            [msg setObject: dec forKey: key];
        }
        return msg;
    }
    
    return [NSMutableDictionary dictionaryWithDictionary: message];
}

-(NSString*) getDecryptedString:(NSString*)disc
{
    NSString * returnval;
    if(_cipherKey != nil)
    {
        returnval=  [CommonFunction AES128DecryptWithKey:_cipherKey Data:disc];
    }
    else {
        returnval=disc ;
    }
    return returnval;
}

-(NSArray*) getDecryptedArray:(NSArray*)array
{   
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity: array.count];
    for (int i=0; i < array.count; i++) {
        id object= [array objectAtIndex:i];
        if ([object isKindOfClass:[NSString class]]) {
            [messages addObject:[self getDecryptedString:(NSString *)object ]];
        } else if ([object isKindOfClass:[NSArray class]]) {
            [messages addObject:[self getDecryptedArray:(NSArray *)object ]]; 
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            [messages addObject:[self getDecryptedDictionary:(NSDictionary *)object ]];
        }
    }
    return messages;
}

- (void) connection:(PubNubConnection*)connection didCompleteWithResponse:(id)response {
    switch (connection.command) {
        case kCommand_SendMessage: {
            BOOL success = NO;
            NSString* error = nil;
            NSArray *array=nil;
            if(response)
            {
                if ([response isKindOfClass:[NSArray class]])
                {
                    NSArray *arra= (NSArray*)response;
                    if([arra count] > 2)
                    {
                        success = [[arra objectAtIndex:0] boolValue];
                        if(success == NO)
                        {
                            error = [arra objectAtIndex:1];
                        }
                    }
                }
            }

            if (success) {
                NSLog(@"Sent message :%@", response);
                if ([_delegate respondsToSelector:@selector(pubnub:didSucceedPublishingMessageToChannel:withResponce:)]) {
                    [_delegate pubnub:self didSucceedPublishingMessageToChannel:connection.channel withResponce:response];
                }
            } else {
                if (error) {
                    array= [NSArray arrayWithObjects:@"0", error,  nil];
                }else {
                    error=  [NSString stringWithFormat:@"Failed sending message to PubNub channel %@:", connection.channel];
                    array= [NSArray arrayWithObjects:@"0", error,  nil];
                }
                if ([_delegate respondsToSelector:@selector(pubnub:didFailPublishingMessageToChannel:error:)]) {
                    [_delegate pubnub:self didFailPublishingMessageToChannel:connection.channel error:[array description]];
                }
            }
            break;
        }
            
        case kCommand_ReceiveMessage: {
            NSString* timeToken = nil;
            for (ChannelStatus* it in [_subscriptions copy]) {
                if ([it.channel isEqualToString:connection.channel])
                {   
                    if(!it.connected) {
                            // NSLog(@"Disconnected to channel %@",connection.channel);
                        if ([_delegate respondsToSelector:@selector(pubnub:DisconnectToChannel:)]) {
                            [_delegate pubnub:self DisconnectToChannel:connection.channel];
                        }
                        break;
                    }
                }
            }
                // Problem?
            if (response == nil || [timeToken isEqualToString:@"0"] ) {
                for (ChannelStatus* it in [_subscriptions copy]) {
                    if ([it.channel isEqualToString:connection.channel])
                    {                        
                        [_subscriptions removeObject:it];
                        if(it.first) {
                                // NSLog(@"_Disconnected to channel %@",connection.channel);
                            if ([_delegate respondsToSelector:@selector(pubnub:DisconnectToChannel:)]) {
                                [_delegate pubnub:self DisconnectToChannel:connection.channel];
                            }
                        }
                    }
                }
                    // Ensure Connected (Call Time Function)
                    //BOOL is_reconnected = NO;
                [self getTime1];
                if (time_token == 0) {
                        // Reconnect Callback
                    
                    if ([_delegate respondsToSelector:@selector(pubnub:Re_ConnectToChannel:)]) {
                            // NSLog(@"_Reconnecting to channel %@",connection.channel);
                        [_delegate pubnub:self Re_ConnectToChannel:connection.channel];
                    }
                } else {
                    
                    if (!_subscriptions && [_subscriptions count] > 0) {
                        BOOL channel_exist = NO;
                        for (ChannelStatus* it in [_subscriptions copy]) {
                            if ([it.channel isEqualToString:connection.channel])
                            { channel_exist = YES;
                                break;
                            }
                        }
                        
                        if (!channel_exist) {
                            ChannelStatus *cs = [[ChannelStatus alloc] init] ;
                            cs.channel = connection.channel;
                            cs.connected = YES;
                            [_subscriptions addObject:cs];
                        } else {
                                // error_cb.execute("Already Connected");
                            return;
                        }
                    } else {
                            // New Channel
                        ChannelStatus *cs = [[ChannelStatus alloc] init] ;
                        cs.channel = connection.channel;
                        cs.connected = true;
                        _subscriptions = [[NSMutableSet alloc] init];
                        [_subscriptions addObject:cs];
                    }
                    
                    [self _resubscribeToChannel:connection.channel timeToken: [NSString stringWithFormat: @"%d", timeToken]];
                    break;
                }
            }
            else {
                for (ChannelStatus* it in [_subscriptions copy]) {
                    if ([it.channel isEqualToString:connection.channel])
                    {
                            // Connect Callback
                        if (it.first == NO) {
                            it.first = YES;
                            if ([_delegate respondsToSelector:@selector(pubnub:ConnectToChannel:)]) {
                                    // NSLog(@"_Connected to channel %@",connection.channel);
                                [_delegate pubnub:self ConnectToChannel:connection.channel];
                            }
                            break;
                        }
                    }
                }
            }
            
            if ([response isKindOfClass:[NSArray class]]) {
                NSLog(@"Received %i messages from PubNub channel \"%@\"", [[response objectAtIndex:0] count], connection.channel);
                for (id message in [response objectAtIndex:0]) {
                    if ([message isKindOfClass:[NSDictionary class]]) {
                        if ([_delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveDictionary:onChannel:)]) {
                            NSDictionary * disc=[self getDecryptedDictionary:(NSDictionary *)message];
                            [_delegate pubnub:self subscriptionDidReceiveDictionary:disc onChannel:connection.channel]; 
                        }
                    }else if ([message isKindOfClass:[NSArray class]]) {
                        if ([_delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveArray:onChannel:)]) {
                            NSArray * arr=[self getDecryptedArray:(NSArray *)message];
                            [_delegate pubnub:self subscriptionDidReceiveArray:arr onChannel:connection.channel]; 
                        }
                    }else if ([message isKindOfClass:[NSString class]]) {
                        if ([_delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveArray:onChannel:)]) {
                            NSString * str=[self getDecryptedString:(NSString *)message];
                            [_delegate pubnub:self subscriptionDidReceiveString:str onChannel:connection.channel];
                        }
                    }else {
                        if ([_delegate respondsToSelector:@selector(pubnub:subscriptionDidFailWithResponse:onChannel:onChannel:)]) {
                            [_delegate pubnub:self subscriptionDidFailWithResponse:message onChannel:connection.channel];
                        }
                    }
                }
                
                timeToken = [response objectAtIndex:1];
            } else if (response) {
                NSLog(@"Unexpected subscribe response from PubNub");
            }
            if (response) {
                if (timeToken) {
                    [self _resubscribeToChannel:connection.channel timeToken:timeToken];
                } else {
                    [self _resubscribeToChannel:connection.channel];
                }
            } 
            else {
                [self performSelector:@selector(_resubscribeToChannel:) withObject:connection.channel afterDelay:kMinRetryInterval];
            }
            break;
        }
            
        case kCommand_FetchHistory: {
            NSMutableArray *mainArray = [NSMutableArray arrayWithCapacity: 2];
            
            if ([response isKindOfClass:[NSArray class]]) {
                NSLog(@"Fetched %i history messages from PubNub channel \"%@\"", [response count], connection.channel);
                
                for (id message in response) {
                    if ([message isKindOfClass:[NSDictionary class]]) {
                        NSDictionary * disc=[self getDecryptedDictionary:(NSDictionary *)message];
                        [mainArray addObject:disc];
                    }else if ([message isKindOfClass:[NSArray class]]) {
                        NSArray * arr=[self getDecryptedArray:(NSArray *)message];
                        [mainArray addObject:arr];
                    }else if ([message isKindOfClass:[NSString class]]) { 
                        NSString * str=[self getDecryptedString:(NSString *)message];
                        [mainArray addObject:str];
                    }
                }
            } else if (response) {
                NSLog(@"Unexpected history response from PubNub");
            }
            if ([_delegate respondsToSelector: @selector(pubnub:didFetchHistory:forChannel:)]) {
                [_delegate pubnub:self didFetchHistory: [NSArray arrayWithArray: mainArray] forChannel: connection.channel];
            }
            break;
        }
        case kCommand_GetTime: {
            NSDecimalNumber* number = nil;
            if ([response isKindOfClass:[NSArray class]]) {
                NSLog(@"Retrieved PubNub time '%@'", [response objectAtIndex:0]);
                number = [response objectAtIndex:0];
            } else if (response) {
                NSLog(@"Unexpected time response from PubNub");
            }
            if ([_delegate respondsToSelector:@selector(pubnub:didReceiveTime:)]) {
                [_delegate pubnub:self didReceiveTime:(number ? [number doubleValue] : NAN)];
            }
            break;
        }
        default:
                //     NOT_REACHED();
            NSLog(@"ERROR::didCompleteWithResponse Command Not Set..");
            break;
    }
    [_connections removeObject: connection];
}
@end
