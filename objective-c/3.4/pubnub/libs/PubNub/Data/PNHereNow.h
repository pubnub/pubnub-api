//
//  PNHereNow.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannel;


@interface PNHereNow : NSObject


#pragma mark Properties

// Stores reference on list of participants
// uuid
@property (nonatomic, readonly, strong) NSArray *participants;

// Stores reference on how many participants in
// the channel
@property (nonatomic, readonly, assign) unsigned int participantsCount;

// Stores reference on channel which this 'Here now'
// information was generated on PubNub service by client
// request
@property (nonatomic, readonly, strong) PNChannel *channel;

#pragma mark -


@end