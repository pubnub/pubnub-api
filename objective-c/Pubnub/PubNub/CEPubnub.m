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
#define kMaxMessageLength 1800  // From documentation
#define kMaxHistorySize 100  // From documentation
#define kConnectionTimeOut 200.0  // From https://github.com/jazzychad/CEPubnub/blob/master/CEPubnub/CEPubnubRequest.m
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

- (void) dealloc {
    [_channel release];
    [_response release];
    [_data release];
    
    [super dealloc];
}

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    // DCHECK(_response == nil);
    _response = (NSHTTPURLResponse*)[response retain];
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
            [_pubNub connection:self didCompleteWithResponse:nil];
        }
    } else {
        NSLog(@"PubNub request failed with HTTP status code %i", _response.statusCode);
        [_pubNub connection:self didCompleteWithResponse:nil];
    }
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorNotConnectedToInternet)) {
        NSLog(@"PubNub request failed due to missing Internet connection");
    } else {
        NSLog(@"PubNub request failed with error: %@", error);
    }
    [_pubNub connection:self didCompleteWithResponse:nil];
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
    [_connections release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_publishKey release];
    [_subscribeKey release];
    [_secretKey release];
    [_host release];
    
    [super dealloc];
}



-(NSDictionary*) getEncryptedDictionary:(NSDictionary*)message
{
    NSMutableDictionary *msg=[[NSMutableDictionary alloc] init];
    if(_cipherKey != nil)
    {
        NSDictionary* disc=(NSDictionary*)message;
        for (NSString* key in [disc allKeys]) {
            //  NSLog(@"Key::%@",key);
            NSString* val=(NSString*)[disc objectForKey:key];
            
            NSString * dec=  [CommonFunction AES128EncryptWithKey:_cipherKey Data:val];
            //   NSLog(@"enc::%@",dec);
            [msg setObject: dec forKey:key];
        }
    }
    else {
        msg=[[NSMutableDictionary alloc] initWithDictionary:message] ;
    }
    return msg;
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
    
    NSMutableArray *messages=[[NSMutableArray alloc] init];
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
    //   - (void) publishMessage:(id)message toChannel:(NSString*)channel {
    NSString * channel;
    id message;
    if (![arg1 objectForKey:@"channel"]) 
    {
        NSLog(@"ERROR::Channel name not found.");
        
    }else 
    {
        channel= [arg1 objectForKey:@"channel"];
    }
    
    if (![arg1 objectForKey:@"message"] ) 
    {
        NSLog(@"ERROR::Message not found.");
    }
    else 
    {
        message= [arg1 objectForKey:@"message"];
    }
    
    id msg=0;
    if ([message isKindOfClass:[NSString class]]) {
        msg=[self getEncryptedString:(NSString *)message ];
        
    } else if ([message isKindOfClass:[NSArray class]]) {
        msg=[self getEncryptedArray:(NSArray *)message ];
    } else if ([message isKindOfClass:[NSDictionary class]]) {
        msg=[self getEncryptedDictionary:(NSDictionary *)message ];
    }
    
    
    NSString* json = JSONWriteString(msg);
    //   NSLog(@"JSON:::%@",json); 
    if ([json lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > kMaxMessageLength) {
        NSLog(@"PubNub message too long: %i bytes", json.length);
    }
    
    NSString* signature;
    if (_secretKey) {
            //signature = MD5HashedString([NSString stringWithFormat:@"%@/%@/%@/%@/%@", _publishKey, _subscribeKey, _secretKey,         channel, json]);
        
        signature =[CommonFunction HMAC_SHA256withKey:[NSString stringWithFormat:@"%@",_secretKey] Input:[NSString stringWithFormat:@"%@/%@/%@/%@/%@", _publishKey, _subscribeKey, _secretKey,channel, json] ];
    } else {
        signature = @"0";
    }
    NSString* url = [NSString stringWithFormat:@"%@/publish/%@/%@/%@/%@/0/%@", _host, _publishKey, _subscribeKey, signature,
                     [channel urlEscapedString], [json urlEscapedString]];
        // NSLog(@"URL::%@",url);
    //   NSLog(@"signature=== %@",signature);
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_SendMessage
                                                                    channel:channel];
    [_connections addObject:connection];
    [connection release];
}





- (void) _resubscribeToChannel:(NSString*)channel timeToken:(NSString*)timeToken {
    NSString* url = [NSString stringWithFormat:@"%@/subscribe/%@/%@/0/%@", _host, _subscribeKey, [channel urlEscapedString], timeToken];
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_ReceiveMessage
                                                                    channel:channel];
    [_connections addObject:connection];
    [connection release];
}

- (void) _resubscribeToChannel:(NSString*)channel {
    [self _resubscribeToChannel:channel timeToken:kInitialTimeToken];
}

- (void) subscribe:(NSString*)channel {
    if (![self isSubscribedToChannel:channel]) {
        [self _resubscribeToChannel:channel];
        NSLog(@"Did subscribe to PubNub channel \"%@\"", channel);
    } else {
        //   DNOT_REACHED();
        NSLog(@"subscribeToChanneldidCompleteWithResponse isSubscribedToChannel is return true");
    }
}

- (void) unsubscribeFromChannel:(NSString*)channel {
    for (PubNubConnection* connection in _connections) {
        if ((connection.command == kCommand_ReceiveMessage) && (!channel || [connection.channel isEqualToString:channel])) {
            NSLog(@"Did unsubscribe from PubNub channel \"%@\"", connection.channel);
            [connection cancel];
            [_connections removeObject:connection];
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL) isSubscribedToChannel:(NSString*)channel {
    for (PubNubConnection* connection in _connections) {
        if ((connection.command == kCommand_ReceiveMessage) && [connection.channel isEqualToString:channel]) {
            return YES;
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
    [connection release];
}

- (void) getTime {
    NSString* url = [NSString stringWithFormat:@"%@/time/0", _host];
    PubNubConnection* connection = [[PubNubConnection alloc] initWithPubNub:self
                                                                        url:[NSURL URLWithString:url]
                                                                    command:kCommand_GetTime
                                                                    channel:nil];
    [_connections addObject:connection];
    [connection release];
}


+ (NSString *) getUUID
{
    return [CommonFunction generateUuidString];
}

-(NSDictionary*) getDecryptedDictionary:(NSDictionary*)message
{
    NSMutableDictionary *msg=[[NSMutableDictionary alloc] init];
    if(_cipherKey != nil)
    {
        NSDictionary* disc=(NSDictionary*)message;
        for (NSString* key in [disc allKeys]) {
            //    NSLog(@"Key::%@",key);
            NSString* val=(NSString*)[disc objectForKey:key];
            
            NSString * dec=  [CommonFunction AES128DecryptWithKey:_cipherKey Data:val];
            //   NSLog(@"enc::%@",dec);
            [msg setObject: dec forKey:key];
        }
    }
    else {
        msg=[[NSMutableDictionary alloc] initWithDictionary:message] ;
    }
    return msg;
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
    
    NSMutableArray *messages=[[NSMutableArray alloc] init];
    for (int i=0; i<array.count; i++) {
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
            if ([response isKindOfClass:[NSArray class]] && ([response count] == 2)) {
                //  NSLog(@"------>  %@",response);
                success = [[response objectAtIndex:0] boolValue];
                if (success == NO) {
                    error = [response objectAtIndex:1];
                }
            }
            if (success) {
                NSLog(@"Sent message to PubNub channel \"%@\"", connection.channel);
                if ([_delegate respondsToSelector:@selector(pubnub:didSucceedPublishingMessageToChannel:)]) {
                    [_delegate pubnub:self didSucceedPublishingMessageToChannel:connection.channel];
                }
            } else {
                if (response) {
                    NSLog(@"Failed sending message to PubNub channel \"%@\": %@", connection.channel, error);
                }
                if ([_delegate respondsToSelector:@selector(pubnub:didFailPublishingMessageToChannel:error:)]) {
                    [_delegate pubnub:self didFailPublishingMessageToChannel:connection.channel error:error];
                }
            }
            break;
        }
            
        case kCommand_ReceiveMessage: {
            NSString* timeToken = nil;
            if ([response isKindOfClass:[NSArray class]] && ([response count] == 2)) {
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
            } else {
                [self performSelector:@selector(_resubscribeToChannel:) withObject:connection.channel afterDelay:kMinRetryInterval];
            }
            break;
        }
            
        case kCommand_FetchHistory: {
            NSArray* history = nil;
            if ([response isKindOfClass:[NSArray class]]) {
                NSLog(@"Fetched %i history messages from PubNub channel \"%@\"", [response count], connection.channel);
                NSMutableArray *mainArray = [[NSMutableArray alloc] init];
                
                
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
  
                
                history = mainArray;
            } else if (response) {
                NSLog(@"Unexpected history response from PubNub");
            }
            if ([_delegate respondsToSelector:@selector(pubnub:didFetchHistory:forChannel:)]) {
                [_delegate pubnub:self didFetchHistory:history forChannel:connection.channel];
            }
            break;
        }
            
        case kCommand_GetTime: {
            NSDecimalNumber* number = nil;
            if ([response isKindOfClass:[NSArray class]] && ([response count] == 1)) {
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
    [_connections removeObject:connection];
}

@end
