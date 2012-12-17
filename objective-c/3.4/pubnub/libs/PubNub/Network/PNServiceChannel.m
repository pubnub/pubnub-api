//
//  PNServiceChannel.m
//  pubnub
//
//  This channel is required to manage
//  service message sending to PubNub service.
//  Will send messages like:
//      - time
//      - leave
//      - history
//      - here now (list of participants)
//      - "ping" (latency measurement if enabled)
//  
//
//  Created by Sergey Mamontov on 12/15/12.
//
//

#import "PNServiceChannel.h"


#pragma mark Public interface methods

@implementation PNServiceChannel


#pragma mark - Instance methods

/**
 * Initialize service channel creation.
 * As result of channel initialization
 * connection to the PubNub services will
 * be established.
 */
- (id)init {
    
    // Check whether intialization was successful or not
    if((self = [super initWithType:PNConnectionChannelService])) {
        
    }
    
    
    return self;
}


#pragma mark -


@end
