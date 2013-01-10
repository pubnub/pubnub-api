//
//  PNSubscribeRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/10/13.
//
//

#import "PNSubscribeRequest.h"


#pragma mark Protected interface methods

@interface PNSubscribeRequest (Protected)


#pragma mark - Properties

// Stores whether leave request was sent to subscribe
// on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;

#pragma mark -


@end