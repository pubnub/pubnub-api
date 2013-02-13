//
//  PNHereNowRequest+Protected.h
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

#import "PNHereNowRequest.h"


#pragma mark Protected interface implementation

@interface PNHereNowRequest (Protected)


#pragma mark - Properties

// Stores reference on channel for which participants
// list will be requested
@property (nonatomic, readonly, strong) PNChannel *channel;

#pragma mark -


@end
