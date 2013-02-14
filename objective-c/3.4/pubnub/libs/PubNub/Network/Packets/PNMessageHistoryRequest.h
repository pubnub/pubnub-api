//
//  PNMessageHistoryRequest.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


@interface PNMessageHistoryRequest : PNBaseRequest


#pragma mark - Class methods

/**
 * Returns reference on configured history download request
 * which will take into account default values for certain
 * parameters (if passed) to change itself to load full or
 * partial history
 */
+ (PNMessageHistoryRequest *)messageHistoryRequestForChannel:(PNChannel *)channel
                                                        from:(NSDate *)startDate
                                                          to:(NSDate*)endDate
                                                       limit:(NSUInteger)limit
                                              reverseHistory:(BOOL)shouldReverseMessagesInResponse;


#pragma mark - Instance methods

/**
 * Returns reference on initialized request which will take
 * into account all special cases which depends on the values
 * which is passed to it
 */
- (id)initForChannel:(PNChannel *)channel
                from:(NSDate *)startDate
                  to:(NSDate*)endDate
               limit:(NSUInteger)limit
      reverseHistory:(BOOL)shouldReverseMessagesInResponse;


#pragma mark -


@end