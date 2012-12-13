//
//  PNMessagingChannel.m
//  pubnub
//
//  This channel instance is required for
//  messages exchange between client and
//  PubNub service:
//      - channels messages
//      - channels presence events
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNMessagingChannel.h"
#import "PNRequestsImport.h"


#pragma mark Private interface methods

@interface PNMessagingChannel ()


#pragma mark - Properties

// Stores lits of channels (including presence)
// on which this client is subscribed now
@property (nonatomic, strong) NSMutableArray *subscribedChannels;

#pragma mark - Presence management

/**
 * Send leave event to all channels to which
 * client subscribed at this moment
 */
- (void)leave;
- (void)leaveChannel:(PNChannel *)channel;


@end


#pragma mark Public interface methods

@implementation PNMessagingChannel


#pragma mark - Instance methods

/**
 * Initialize messaging channel creation.
 * As result of channel initialization
 * connection to the PubNub services will
 * be established.
 */
- (id)init {
    
    // Check whether intialization was successful or not
    if((self = [super initWithType:PNConnectionChannelMessagin])) {
        
        self.subscribedChannels = [NSMutableArray array];
    }
    
    
    return self;
}

#pragma mark - Presence management

- (void)leave {
    
    // Check whether there some channels which
    // user can leave
    if([self.subscribedChannels count] > 0) {
        
        [self scheduleRequest:[PNLeaveRequest leaveRequestForChannels:self.subscribedChannels]];
    }
}

- (void)leaveChannel:(PNChannel *)channel {
    
    [self scheduleRequest:[PNLeaveRequest leaveRequestForChannel:channel]];
}


#pragma mark - Channels management

- (void)subscribeForChannel:(PNChannel *)channel {
        
    [self leave];
}

- (void)unsubscribeFromChannel:(PNChannel *)channel {
    
}

- (void)subscribeForChannels:(NSArray *)channels {
    
    [self leave];
}

- (void)unsubscribeFromChannels:(NSArray *)channels {
    
}


#pragma mark - Prsence observation management

- (void)addPresenceObservationForChannel:(PNChannel *)channel {
    
}

- (void)removePresenceObservationForChannel:(PNChannel *)channel {
    
}

- (void)addPresenceObservationForChannels:(NSArray *)channels {
    
}

- (void)removePresenceObservationForChannelw:(NSArray *)channels {
    
}

#pragma mark -


@end
