//
//  PNLeaveRequest.h
//  pubnub
//
//  This request instance is used to describe
//  channel(s) leave request which will
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


@interface PNLeaveRequest : PNBaseRequest


#pragma mark - Class methods

+ (PNLeaveRequest *)leaveRequestForChannel:(PNChannel *)channel;
+ (PNLeaveRequest *)leaveRequestForChannels:(NSArray *)channels;


#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel;
- (id)initForChannels:(NSArray *)channels;

#pragma mark -


@end
