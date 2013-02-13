//
//  PNPresenceEvent+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNPresenceEvent.h"


#pragma mark Static

// This enum represents all data keys which is used in
// presence response dictionary from JSON
struct PNPresenceEventDataKeysStruct {

    // Stores presence event type
    __unsafe_unretained NSString *action;
    // Stores presence occurrence time
    __unsafe_unretained NSString *timestamp;
    // Stores reference on person who triggered presence event
    __unsafe_unretained NSString *uuid;
    // Stores reference on current number of persons on channel
    // in which this event was triggered
    __unsafe_unretained NSString *occupancy;
};

static struct PNPresenceEventDataKeysStruct PNPresenceEventDataKeys = {
    .action = @"action",
    .timestamp = @"timestamp",
    .uuid = @"uuid",
    .occupancy = @"occupancy"
};


#pragma mark - Protected interface methods

@interface PNPresenceEvent (Protected)


#pragma mark - Properties

// Stores reference on channel on which this event
// is fired
@property (nonatomic, assign) PNChannel *channel;

// Stores reference on presence occurrence
// date
@property (nonatomic, strong) NSDate *date;

#pragma mark -


@end
