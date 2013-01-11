//
//  PNChannel.m
//  pubnub
//
//  This class allow to parse response from server
//  into logical units:
//      - update time token
//      - channels on which event occurred in pair with event
//
//
//  Created by moonlight on 1/1/13.
//
//


#import "PNResponseParser.h"
#import "PNChannelPresence+Protected.h"
#import "PNPresenceEvent.h"
#import "PNResponse.h"
#import "PNPresenceEvent+Protected.h"
#import "PNMessage.h"


#pragma mark Static

// Stores reference on index under which request
// execution status code is stored
static NSUInteger const kPNResponseStatusCodeElementIndex = 0;

// Stores reference on index under which events
// list is stored
static NSUInteger const kPNResponseEventsListElementIndex = 0;

// Stores reference on index under which request
// execution status description is stored
static NSUInteger const kPNResponseStatusCodeDescriptionElementIndex = 1;

// Stores reference on time token element index in
// response for request status
static NSUInteger const kPNResponseTimeTokenElementIndexForStatus = 2;

// Stores reference on index under which channels list
// is stored
static NSUInteger const kPNResponseChannelsListElementIndex = 2;

// Stores reference on time token element index in
// response for events
static NSUInteger const kPNResponseTimeTokenElementIndexForEvent = 1;



// Stores reference on key which stores reference on
// action name which was confirmed in response
static NSString * const kPNResponseActionKey = @"action";

// Stores reference on key which stores list of unique
// user identifiers in channel
static NSString * const kPNResponseUUIDKey = @"uuids";

// Stores reference on key which stores error description
static NSString * const kPNResponseErrorMessageKey = @"error";


#pragma mark - Private interface methods

@interface PNResponseParser ()


#pragma mark - Properties

// Stores reference on update time token (for
// event/message or initial subscription)
@property (nonatomic, copy) NSString *updateTimeToken;

// Stores reference on whether request has been completed
// with error or not
@property (nonatomic, assign, getter = isProcessed) BOOL processed;

// Stores reference on message which arrived with response
// on request processing
@property (nonatomic, copy) NSString *statusDescription;

// Stores reference on action name
@property (nonatomic, copy) NSString *actionName;

// Stores reference on error which occurred during request
// processing
@property (nonatomic, strong) PNError *error;

// Stores reference on list of participants in requested
// channel
@property (nonatomic, strong) NSArray *participants;

// Stores reference on list of messages/events
// received in single response
@property (nonatomic, strong) NSArray *events;


#pragma mark - Instance methods

/**
 * Returns reference on initialized parser for concrete
 * response
 */
- (id)initWithResponse:(PNResponse *)response;


@end


#pragma mark - Public interface methods

@implementation PNResponseParser


#pragma mark - Class methods

+ (PNResponseParser *)parserForResponse:(PNResponse *)response {

    return [[[self class] alloc] initWithResponse:response];
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        if ([response.response isKindOfClass:[NSArray class]]) {

            NSArray *responseData = response.response;

            // Check whether first element in array is array as well
            // (which will mean that response holds set of events for
            // set of channels or at least one channel)
            if ([[responseData objectAtIndex:0] isKindOfClass:[NSArray class]]) {

                self.processed = YES;

                // Check whether time token is available or not
                if ([responseData count] > kPNResponseTimeTokenElementIndexForEvent) {

                    self.updateTimeToken = [responseData objectAtIndex:kPNResponseTimeTokenElementIndexForEvent];
                }

                // Retrieving list of events
                NSArray *events = [responseData objectAtIndex:kPNResponseEventsListElementIndex];

                // Retrieving list of channels on which events fired
                NSArray *channels = nil;
                if ([responseData count] > kPNResponseChannelsListElementIndex) {

                    channels = [[responseData objectAtIndex:kPNResponseChannelsListElementIndex]
                            componentsSeparatedByString:@","];
                }

                if ([events count] > 0) {

                    NSMutableArray *eventObjects = [NSMutableArray arrayWithCapacity:[events count]];
                    [events enumerateObjectsUsingBlock:^(id event,
                                                         NSUInteger eventIdx,
                                                         BOOL *eventEnumeratorStop) {

                        BOOL isPresenceEvent = NO;

                        PNChannel *channel = nil;
                        if ([channels count] > 0) {

                            // Retrieve reference on channel on which event is occurred
                            channel = [PNChannel channelWithName:[channels objectAtIndex:eventIdx]];

                            // Checking whether event occurred on presence observing channel
                            // or no and retrieve reference on original channel
                            if ([channel isPresenceObserver]) {

                                channel = [(PNChannelPresence *)channel observedChannel];
                            }
                        }

                        // Checking whether event is object or not
                        if ([event isKindOfClass:[NSDictionary class]] && [PNPresenceEvent isPresenceEventObject:event]) {

                            isPresenceEvent = YES;

                            PNPresenceEvent *eventObject = [PNPresenceEvent presenceEventForResponse:event];
                            eventObject.channel = channel;
                            [eventObjects addObject:eventObject];
                        }

                        if (!isPresenceEvent) {

                            PNMessage *message = [PNMessage new];
                            [eventObjects addObject:message];
                        }
                    }];

                    self.events = eventObjects;
                }
            }
            // Check whether there is only single item in array which will mean
            // that this is time token
            else if([responseData count] == 1) {

                self.processed = YES;
                self.updateTimeToken = [responseData lastObject];
            }
            // Looks like this is response with status message
            else {

                self.processed = [[responseData objectAtIndex:kPNResponseStatusCodeElementIndex] intValue] != 0;
                self.statusDescription = [responseData objectAtIndex:kPNResponseStatusCodeDescriptionElementIndex];

                if (!self.isProcessed) {

                    self.error = [PNError errorWithResponseErrorMessage:self.statusDescription];
                }

                if ([responseData count] > kPNResponseTimeTokenElementIndexForStatus) {

                    self.updateTimeToken = [responseData objectAtIndex:kPNResponseTimeTokenElementIndexForStatus];
                }
            }
        }
        else {

            NSDictionary *responseData = response.response;

            // Check whether response arrived as result of specific action
            // execution
            if ([responseData objectForKey:kPNResponseActionKey]) {

                self.processed = YES;
                self.actionName = [responseData valueForKey:kPNResponseActionKey];
            }
            else if ([responseData objectForKey:kPNResponseUUIDKey]) {

                self.processed = YES;
                self.participants = [responseData valueForKey:kPNResponseUUIDKey];
            }
            else if ([responseData objectForKey:kPNResponseErrorMessageKey]) {

                self.processed = NO;
                self.error = [PNError errorWithResponseErrorMessage:[responseData valueForKey:kPNResponseErrorMessageKey]];
            }
        }
    }


    return self;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"\nIS REQUEST SUCCESSFULLY PROCESSED? %@\nUPDATE TIME TOKEN: %@\nSTATUS DESCRIPTION: %@\nERROR: %@\nACTION NAME: %@\nPARTICIPANTS: %@\nEVENTS: %@",
                    self.isProcessed?@"YES":@"NO", self.updateTimeToken, self.statusDescription, self.error,
                    self.actionName, self.participants, self.events];
}

#pragma mark -


@end