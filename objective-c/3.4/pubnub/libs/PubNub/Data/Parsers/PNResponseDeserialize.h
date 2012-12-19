//
//  PNResponseDeserialize.h
//  pubnub
//
//  This class was created to help deserialize
//  responses which connection recieves over the
//  stream opened on sockets.
//  Server returns formatted HTTP headers with response
//  body which should be extracted.
//
//
//  Created by Sergey Mamontov on 12/19/12.
//
//

#import <Foundation/Foundation.h>


@interface PNResponseDeserialize : NSObject


#pragma mark Instance methods

/**
 * Will parse response which arrived from PubNub service
 * and update data holder to remove parsed data from it
 */
- (NSArray *)parseResponseData:(NSMutableData *)data;

/**
 * Will search for valid portions of response in provided
 * data (will search for complete HTTP header and complete
 * response after that headers)
 */
- (BOOL)hasMoreValidResponseInData:(NSMutableData *)data;

#pragma mark -


@end
