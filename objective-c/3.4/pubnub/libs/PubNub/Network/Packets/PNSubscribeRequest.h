//
//  PNSubscribeRequest.h
//  pubnub
//
//  This request object is used to describe
//  channel(s) subscription request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


@interface PNSubscribeRequest : PNBaseRequest


#pragma mark - Class methods

+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel;
+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels;


#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel;
- (id)initForChannels:(NSArray *)channels;

@end
