//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


@interface PNHereNowRequest : PNBaseRequest


#pragma mark Class methods

+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel;


#pragma mark - Instance methods

- (id)initWithChannel:(PNChannel *)channel;

#pragma mark -


@end