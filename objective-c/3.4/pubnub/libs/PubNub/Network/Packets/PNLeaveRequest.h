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


#pragma mark - Properties

// Stores reference on channels list
@property (nonatomic, readonly, strong) NSArray *channels;


#pragma mark - Class methods

+ (PNLeaveRequest *)leaveRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isLeavingByUserRequest;
+ (PNLeaveRequest *)leaveRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest;


#pragma mark - Instance methods

- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest;

#pragma mark -


@end
