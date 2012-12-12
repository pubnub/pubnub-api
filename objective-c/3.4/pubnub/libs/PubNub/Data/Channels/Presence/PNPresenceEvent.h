//
//  PNPresenceEvent.h
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

#import <Foundation/Foundation.h>


@interface PNPresenceEvent : NSObject


#pragma mark Class methods

/**
 * Will return event object which will describe 
 * what kind of presence event occurred and provide
 * all data from it to the user.
 * If multiple presence events will be found in
 * provided response this method will return array
 * of events.
 */
+ (id)presenceEventForResponse:(id)presenceResponse;


#pragma mark - Instance methods

/**
 * Initialize presence event instance from 
 * PubNub service response
 */
- (id)initWithResponse:(id)presenceResponse;

#pragma mark -


@end
