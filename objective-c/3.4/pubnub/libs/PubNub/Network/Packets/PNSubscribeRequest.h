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


#pragma mark - Properties

// Stores reference on list of channels on which client
// should subscribe
@property (nonatomic, readonly, strong) NSArray *channels;


#pragma mark - Class methods

+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest;
+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest;


#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest;
- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest;

@end
