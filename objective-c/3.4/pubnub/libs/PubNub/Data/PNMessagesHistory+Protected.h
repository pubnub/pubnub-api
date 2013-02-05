//
//  PNMessagesHistory+Protected.h
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

#import "PNMessagesHistory.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Protected interface methods

@interface PNMessagesHistory (Protected)


#pragma mark - Properties

// Stores reference on history time frame start date
@property (nonatomic, strong) NSDate *startDate;

// Stores reference on history time frame end date
@property (nonatomic, strong) NSDate *endDate;

// Store reference on channel for which history has been
// downloaded
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on list of messages which has been downloaded
@property (nonatomic, strong) NSArray *messages;

#pragma mark -


@end



