//
//  PNMessagesHistory+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/20/13.
//
//

#import "PNMessagesHistory.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Protected interface methods

@interface PNMessagesHistory (Protected)


#pragma mark - Properties

// Stores reference on history time frame start date
@property (nonatomic, readonly, strong) NSDate *startDate;

// Stores reference on history time frame end date
@property (nonatomic, readonly, strong) NSDate *endDate;

// Store reference on channel for which history has been
// downloaded
@property (nonatomic, readonly, strong) PNChannel *channel;

// Stores reference on list of messages which has been downloaded
@property (nonatomic, readonly, strong) NSArray *messages;

#pragma mark -


@end



