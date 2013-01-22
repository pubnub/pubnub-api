//
//  PNHereNowRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/22/13.
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
