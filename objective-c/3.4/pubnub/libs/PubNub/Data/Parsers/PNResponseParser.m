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
#import "PNHereNowResponseParser+Protected.h"
#import "PNActionResponseParser+Protected.h"
#import "PNOperationStatusResponseParser.h"
#import "PNErrorResponseParser+Protected.h"
#import "PNChannelEventsResponseParser.h"
#import "PNPresenceEvent+Protected.h"
#import "PNTimeTokenResponseParser.h"
#import "PNHereNowResponseParser.h"
#import "PNActionResponseParser.h"
#import "PNErrorResponseParser.h"
#import "PNResponse.h"
#import "PNChannelHistoryParser.h"



#pragma mark - Private interface methods

@interface PNResponseParser ()


#pragma mark - Class methods

/**
 * Retrieve reference on class of parser which should be used
 * to parse response which arrived from PubNub service
 */
+ (Class)classForResponse:(PNResponse *)response;


@end


#pragma mark - Public interface methods

@implementation PNResponseParser


#pragma mark - Class methods

+ (PNResponseParser *)parserForResponse:(PNResponse *)response {

    return [[[self classForResponse:response] alloc] initWithResponse:response];
}

+ (Class)classForResponse:(PNResponse *)response {

    Class parserClass = nil;

    if ([response.response isKindOfClass:[NSArray class]]) {

        NSArray *responseData = response.response;

        // Check whether there is only single item in array which will mean
        // that this is time token
        if([responseData count] == 1) {

            parserClass = [PNTimeTokenResponseParser class];
        }
        // Check whether first element in array is array as well
        // (which will mean that response holds set of events for
        // set of channels or at least one channel)
        else if ([[responseData objectAtIndex:0] isKindOfClass:[NSArray class]]) {

            // Check whether there is 3 elements in response array or not
            // (depending on whether two last elements is number or not,
            // this will mean whether response is for history or not)
            if ([responseData count] == 3 &&
                [[responseData objectAtIndex:1] isKindOfClass:[NSNumber class]] &&
                [[responseData objectAtIndex:2] isKindOfClass:[NSNumber class]]) {

                parserClass = [PNChannelHistoryParser class];
            }
            else {

                parserClass = [PNChannelEventsResponseParser class];
            }
        }
        // Looks like this is response with status message
        else {

            parserClass = [PNOperationStatusResponseParser class];
        }
    }
    else {

        NSDictionary *responseData = response.response;

        // Check whether response arrived as result of specific action
        // execution
        if ([responseData objectForKey:kPNResponseActionKey]) {

            parserClass = [PNActionResponseParser class];
        }
        // Check whether result is result for "Here now" request
        // execution or not
        else if ([responseData objectForKey:kPNResponseUUIDKey] &&
                 [responseData objectForKey:kPNResponseOccupancyKey]) {

            parserClass = [PNHereNowResponseParser class];
        }
        // Check whether error report response arrived
        else if ([responseData objectForKey:kPNResponseErrorMessageKey]) {

            parserClass = [PNErrorResponseParser class];
        }
    }


    return parserClass;
}


#pragma mark - Instance methods

/**
 * Returns reference on parsed data
 * (template method, actual implementation is in
 * subclasses)
 */
- (id)parsedData {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);


    return nil;
}

#pragma mark -


@end