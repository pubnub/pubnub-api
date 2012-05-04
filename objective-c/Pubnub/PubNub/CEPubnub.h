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

#import <Foundation/Foundation.h>

@class CEPubnub;

@protocol CEPubnubDelegate <NSObject>
@optional
- (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString*)channel;
- (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error;  // "error" may be nil

//- (void) pubnub:(PubNub*)pubnub didReceiveMessage:(NSDictionary*)message onChannel:(NSString*)channel;

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)message onChannel:(NSString *)channel;



- (void) pubnub:(CEPubnub*)pubnub didFetchHistory:(NSArray*)messages forChannel:(NSString*)channel;  // "messages" will be nil on failure
- (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time;  // "time" will be NAN on failure
@end

// All operations happen on the main thread
// Messages must be JSON compatible and less than 1800 bytes once serialized
@interface CEPubnub : NSObject {
@private
  id<CEPubnubDelegate> _delegate;
  NSString* _publishKey;
  NSString* _subscribeKey;
  NSString* _secretKey;
  NSString* _host;
  NSString* _cipherKey;
  
  NSMutableSet* _connections;
}
@property(nonatomic, assign) id<CEPubnubDelegate> delegate;
- (CEPubnub*) initWithSubscribeKey:(NSString*)subscribeKey useSSL:(BOOL)useSSL;
- (CEPubnub*) initWithPublishKey:(NSString*)publishKey
                  subscribeKey:(NSString*)subscribeKey
                     secretKey:(NSString*)secretKey
                        useSSL:(BOOL)useSSL;
- (CEPubnub*) initWithPublishKey:(NSString*)publishKey  // May be nil if -publishMessage:toChannel: is never used
                  subscribeKey:(NSString*)subscribeKey
                     secretKey:(NSString*)secretKey  // May be nil if -publishMessage:toChannel: is never used
                        useSSL:(BOOL)useSSL
                     cipherKey:(NSString*)cipherKey  
                        origin:(NSString*)origin;

- (CEPubnub*) initWithPublishKey:(NSString*)publishKey
                  subscribeKey:(NSString*)subscribeKey
                     secretKey:(NSString*)secretKey
                     cipherKey:(NSString*)cipherKey
                        useSSL:(BOOL)useSSL;

//- (void) publishMessage:(id)message toChannel:(NSString*)channel;
//- (void) fetchHistory:(NSUInteger)limit forChannel:(NSString*)channel;

- (void) publish:(NSDictionary * )arg1;
- (void) publish:(NSString * )message onChannel:(NSString *) channel;
- (void) fetchHistory:(NSDictionary * )arg1;

- (void) unsubscribeFromAllChannels;
- (void) getTime;
+ (NSString*) getUUID;
- (void) subscribe:(NSString*)channel;  // Does nothing if already subscribed
- (void) unsubscribeFromChannel:(NSString*)channel;  // Does nothing if not subscribed
- (BOOL) isSubscribedToChannel:(NSString*)channel;
@end
