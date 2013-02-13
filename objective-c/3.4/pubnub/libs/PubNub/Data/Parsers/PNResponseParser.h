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


#pragma mark - Class methods

/**
 * Returns reference on parser which completed it's job and
 * can provide data for response
 */
+ (PNResponseParser *)parserForResponse:(PNResponse *)response;


#pragma mark - Instance methods

/**
 * Returns reference on parsed data
 * (template method, actual implementation is in
 * subclasses)
 */
- (id)parsedData;

@end