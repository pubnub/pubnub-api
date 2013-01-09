//
//  PNChannel.h
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


#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNResponse, PNError;


@interface PNResponseParser : NSObject


#pragma mark - Properties

// Stores reference on update time token (for
// event/message or initial subscription)
@property (nonatomic, readonly, copy) NSString *updateTimeToken;

// Stores reference on whether request has been completed
// with error or not
@property (nonatomic, readonly, assign, getter = isProcessed) BOOL processed;

// Stores reference on message which arrived with response
// on request processing
@property (nonatomic, readonly, copy) NSString *statusDescription;

// Stores reference on action name
@property (nonatomic, readonly, copy) NSString *actionName;

// Stores reference on error which occurred during request
// processing
@property (nonatomic, readonly, strong) PNError *error;

// Stores reference on list of participants in requested
// channel
@property (nonatomic, readonly, strong) NSArray *participants;

// Stores reference on list of messages/events
// received in single response
@property (nonatomic, readonly, strong) NSArray *events;


#pragma mark - Class methods

/**
 * Returns reference on parser which completed it's job and
 * can provide data for response
 */
+ (PNResponseParser *)parserForResponse:(PNResponse *)response;

@end