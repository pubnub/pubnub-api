//
//  PNMessageHistoryRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/22/13.
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
