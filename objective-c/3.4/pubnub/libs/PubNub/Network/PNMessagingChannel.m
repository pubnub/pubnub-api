//
//  PNMessagingChannel.m
//  pubnub
//
//  This channel instance is required for
//  messages exchange between client and
//  PubNub service:
//      - channels messages
//      - channels presence events
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNMessagingChannel.h"
#import "PNRequestsImport.h"


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
        
        
    }
    
    
    return self;
}

#pragma mark - Presence management

- (void)leave {
    
    [self scheduleRequest];
}


#pragma mark - Channels management

- (void)subscribeForChannel:(PNChannel *)channel {
    
    
}

- (void)unsubscribeFromChannel:(PNChannel *)channel {
    
}

- (void)subscribeForChannels:(NSArray *)channels {
    
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
