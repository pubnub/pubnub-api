//
//  PNPresenceEvent.m
//  pubnub
//
//  Object which is used to describe concrete
//  presence event which arrived from PubNub
//  services.
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNPresenceEvent+Protected.h"


#pragma mark Private interface methods

@interface PNPresenceEvent ()


#pragma mark Properties

// Stores reference on presence event type
@property (nonatomic, assign) PNPresenceEventType type;

// Stores reference on presence occurrence
// date
@property (nonatomic, strong) NSDate *date;

// Stores reference on user identifier which
// is triggered presence event
@property (nonatomic, copy) NSString *uuid;

// Stores reference on number of persons in channel
// on which this event is occurred
@property (nonatomic, assign) NSUInteger occupancy;

// Stores reference on channel on which this event
// is fired
@property (nonatomic, assign) PNChannel *channel;


@end


#pragma mark - Public interface methods

@implementation PNPresenceEvent


#pragma mark Class methods

+ (id)presenceEventForResponse:(id)presenceResponse {
    
    return [[[self class] alloc] initWithResponse:presenceResponse];
}

+ (BOOL)isPresenceEventObject:(NSDictionary *)event {

    return [event objectForKey:PNPresenceEventDataKeys.action] != nil &&
           [event objectForKey:PNPresenceEventDataKeys.timestamp] != nil &&
           [event objectForKey:PNPresenceEventDataKeys.uuid] != nil &&
           [event objectForKey:PNPresenceEventDataKeys.occupancy] != nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(id)presenceResponse {
    
    // Check whether intialization successful or not
    if((self = [super init])) {

        // Extracting event type from response
        self.type = PNPresenceEventJoin;
        NSString *type = [presenceResponse valueForKey:PNPresenceEventDataKeys.action];
        if ([type isEqualToString:@"leave"]) {

            self.type = PNPresenceEventLeave;
        }
        else if ([type isEqualToString:@"timeout"]) {

            self.type = PNPresenceEventTimeout;
        }

        // Extracting event date from response
        NSNumber *timestamp = [presenceResponse valueForKey:PNPresenceEventDataKeys.timestamp];
        self.date = [NSDate dateWithTimeIntervalSince1970:PNUnixTimeStampFromTimeToken(timestamp)];

        // Extracting user identifier from response
        self.uuid = [presenceResponse valueForKey:PNPresenceEventDataKeys.uuid];

        // Extracting channel occupancy from response
        self.occupancy = [[presenceResponse valueForKey:PNPresenceEventDataKeys.occupancy] unsignedIntegerValue];
    }
    
    
    return self;
}

- (NSString *)description {

    NSString *action = @"join";
    if (self.type == PNPresenceEventLeave) {

        action = @"leave";
    }
    else if (self.type == PNPresenceEventTimeout) {

        action = @"timeout";
    }


    return [NSString stringWithFormat:@"%@ \nEVENT: %@\nUSER IDENTIFIER: %@\nDATE: %@\nOCCUPANCY: %d\nCHANNEL: %@",
                    NSStringFromClass([self class]), action, self.uuid, self.date, self.occupancy, self.channel];
}

#pragma mark -


@end
