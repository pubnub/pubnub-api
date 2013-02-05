//
//  PNMessageHistoryRequest+Protected.h
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


#import "PNMessageHistoryRequest.h"


#pragma mark Protected interface implementation

@interface PNMessageHistoryRequest (Protected)


#pragma mark - Properties

// Stores reference on channel for which history should
// be pulled out
@property (nonatomic, readonly, strong) PNChannel *channel;

#pragma mark -


@end
