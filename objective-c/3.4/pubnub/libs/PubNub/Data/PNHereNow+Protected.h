//
//  PNHereNow+Protected.h
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

#import "PNHereNow.h"


#pragma mark Private interface methods

@interface PNHereNow (Protected)


#pragma mark - Properties

// Stores reference on list of participants
// uuid
@property (nonatomic, strong) NSArray *participants;

// Stores reference on how many participants in
// the channel
@property (nonatomic, assign) unsigned int participantsCount;

// Stores reference on channel which this 'Here now'
// information was generated on PubNub service by client
// request
@property (nonatomic, strong) PNChannel *channel;

#pragma mark -


@end
