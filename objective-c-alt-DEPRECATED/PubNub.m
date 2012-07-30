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

#import "PubNub.h"
#import "JSON.h"
#import "Crypto.h"
#import "Logging.h"
#import "Extensions_Foundation.h"

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
  PubNub* _pubNub;
  Command _command;
  NSString* _channel;
  
  NSHTTPURLResponse* _response;
  NSMutableData* _data;
}
@property(nonatomic, readonly) Command command;
@property(nonatomic, readonly) NSString* channel;
@property(nonatomic, readonly) NSData* data;
- (id) initWithPubNub:(PubNub*)pubNub url:(NSURL*)url command:(Command)command channel:(NSString*)channel;
@end

@interface PubNub ()
- (void) connection:(PubNubConnection*)connection didCompleteWithResponse:(id)response;
@end

@implementation PubNubConnection

@synthesize command=_command, channel=_channel, data=_data;

- (id) initWithPubNub:(PubNub*)pubNub url:(NSURL*)url command:(Command)command channel:(NSString*)channel {
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                     timeoutInterval:kConnectionTimeOut];
  [request setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
  [request setValue:@"close" forHTTPHeaderField:@"Connection"];
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
  DCHECK(_response == nil);
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
    NSString* contentType = [[_response allHeaderFields] objectForKey:@"Content-Type"];
    if ([contentType hasPrefix:@"text/javascript"] && [contentType containsString:@"UTF-8"]) {  // Should be [text/javascript; charset="UTF-8"] but is sometimes different on 3G
      [_pubNub connection:self didCompleteWithResponse:JSONParseData(_data)];
    } else {
      LOG_ERROR(@"PubNub request returned unexpected content type: %@", contentType);
      [_pubNub connection:self didCompleteWithResponse:nil];
    }
  } else {
    LOG_ERROR(@"PubNub request failed with HTTP status code %i", _response.statusCode);
    [_pubNub connection:self didCompleteWithResponse:nil];
  }
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
  if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorNotConnectedToInternet)) {
    LOG_VERBOSE(@"PubNub request failed due to missing Internet connection");
  } else {
    LOG_ERROR(@"PubNub request failed with error: %@", error);
  }
  [_pubNub connection:self didCompleteWithResponse:nil];
}

@end

@implementation PubNub

@synthesize delegate=_delegate;

- (PubNub*) initWithSubscribeKey:(NSString*)subscribeKey useSSL:(BOOL)useSSL {
  return [self initWithPublishKey:nil subscribeKey:subscribeKey secretKey:nil useSSL:useSSL origin:kDefaultOrigin];
}

- (PubNub*) initWithPublishKey:(NSString*)publishKey
                  subscribeKey:(NSString*)subscribeKey
                     secretKey:(NSString*)secretKey
                        useSSL:(BOOL)useSSL {
  return [self initWithPublishKey:publishKey subscribeKey:subscribeKey secretKey:secretKey useSSL:useSSL origin:kDefaultOrigin];
}

- (PubNub*) initWithPublishKey:(NSString*)publishKey
                  subscribeKey:(NSString*)subscribeKey
                     secretKey:(NSString*)secretKey
                        useSSL:(BOOL)useSSL
                        origin:(NSString*)origin {
  if ((self = [super init])) {
    _publishKey = [publishKey copy];
    _subscribeKey = [subscribeKey copy];
    _secretKey = [secretKey copy];
    _host = [[NSString alloc] initWithFormat:@"%@://%@", useSSL ? @"https" : @"http", origin];
    
    _connections = [[NSMutableSet alloc] init];
  }
  return self;
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

- (void) publishMessage:(id)message toChannel:(NSString*)channel {
  NSString* json = JSONWriteString(message);
  if ([json lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > kMaxMessageLength) {
    LOG_ABORT(@"PubNub message too long: %i bytes", json.length);
  }
  
  NSString* signature;
  if (_secretKey) {
    signature = MD5HashedString([NSString stringWithFormat:@"%@/%@/%@/%@/%@", _publishKey, _subscribeKey, _secretKey,
                                                           channel, json]);
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

- (void) subscribeToChannel:(NSString*)channel {
  if (![self isSubscribedToChannel:channel]) {
    [self _resubscribeToChannel:channel];
    LOG_VERBOSE(@"Did subscribe to PubNub channel \"%@\"", channel);
  } else {
    DNOT_REACHED();
  }
}

- (void) unsubscribeFromChannel:(NSString*)channel {
  for (PubNubConnection* connection in _connections) {
    if ((connection.command == kCommand_ReceiveMessage) && (!channel || [connection.channel isEqualToString:channel])) {
      LOG_VERBOSE(@"Did unsubscribe from PubNub channel \"%@\"", connection.channel);
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
  if (limit > kMaxHistorySize) {
    LOG_ABORT(@"PubNub history too large: %i", limit);
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

- (void) connection:(PubNubConnection*)connection didCompleteWithResponse:(id)response {
  switch (connection.command) {
    
    case kCommand_SendMessage: {
      BOOL success = NO;
      NSString* error = nil;
      if ([response isKindOfClass:[NSArray class]] && ([response count] == 2)) {
        success = [[response objectAtIndex:0] boolValue];
        if (success == NO) {
          error = [response objectAtIndex:1];
        }
      }
      if (success) {
        LOG_VERBOSE(@"Sent message to PubNub channel \"%@\"", connection.channel);
        if ([_delegate respondsToSelector:@selector(pubnub:didSucceedPublishingMessageToChannel:)]) {
          [_delegate pubnub:self didSucceedPublishingMessageToChannel:connection.channel];
        }
      } else {
        if (response) {
          LOG_ERROR(@"Failed sending message to PubNub channel \"%@\": %@", connection.channel, error);
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
        if ([_delegate respondsToSelector:@selector(pubnub:didReceiveMessage:onChannel:)]) {
          LOG_VERBOSE(@"Received %i messages from PubNub channel \"%@\"", [[response objectAtIndex:0] count], connection.channel);
          for (id message in [response objectAtIndex:0]) {
            [_delegate pubnub:self didReceiveMessage:message onChannel:connection.channel];
          }
        }
        timeToken = [response objectAtIndex:1];
      } else if (response) {
        LOG_ERROR(@"Unexpected subscribe response from PubNub");
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
        LOG_VERBOSE(@"Fetched %i history messages from PubNub channel \"%@\"", [response count], connection.channel);
        history = response;
      } else if (response) {
        LOG_ERROR(@"Unexpected history response from PubNub");
      }
      if ([_delegate respondsToSelector:@selector(pubnub:didFetchHistory:forChannel:)]) {
        [_delegate pubnub:self didFetchHistory:history forChannel:connection.channel];
      }
      break;
    }
    
    case kCommand_GetTime: {
      NSDecimalNumber* number = nil;
      if ([response isKindOfClass:[NSArray class]] && ([response count] == 1)) {
        LOG_VERBOSE(@"Retrieved PubNub time '%@'", [response objectAtIndex:0]);
        number = [response objectAtIndex:0];
      } else if (response) {
        LOG_ERROR(@"Unexpected time response from PubNub");
      }
      if ([_delegate respondsToSelector:@selector(pubnub:didReceiveTime:)]) {
        [_delegate pubnub:self didReceiveTime:(number ? [number doubleValue] : NAN)];
      }
      break;
    }
    
    default:
      NOT_REACHED();
      break;
    
  }
  [_connections removeObject:connection];
}

@end
