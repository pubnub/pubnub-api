//
//  PNPresenceEvent.m
//  pubnub
//
//  Object which is used to describe concrete
//  presence event which arrived from PubNub
//  services.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNPresenceEvent.h"


#pragma mark Private interface methods

@interface PNPresenceEvent ()


#pragma mark - Class methods

/**
 * This method will analyze and filter response
 * (filtering from channel messages is working in
 * multiplex mode) and return how many presence
 * events occurred
 */
+ (NSUInteger)numberOfEventsInResponse:(id)presenceResponse;


@end


#pragma mark - Public interface methods

@implementation PNPresenceEvent


#pragma mark Class methods

+ (id)presenceEventForResponse:(id)presenceResponse {
    
    return [[[self class] alloc] initWithResponse:presenceResponse];
}

+ (NSUInteger)numberOfEventsInResponse:(id)presenceResponse {
    
    return 0;
}


#pragma mark - Instance methods

- (id)initWithResponse:(id)presenceResponse {
    
    // Check whether intialization successful or not
    if((self = [super init])) {
        
    }
    
    
    return self;
}

#pragma mark -


@end
