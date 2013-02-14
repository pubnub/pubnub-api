//
//  PNSubscribeRequest+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
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