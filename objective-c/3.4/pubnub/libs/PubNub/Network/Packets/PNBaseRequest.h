//
//  PNBaseRequest.h
//  pubnub
//
//  Base request class which will allow to
//  serialize specified data into format
//  which will be sent over socket connection.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNWriteBuffer;


@interface PNBaseRequest : NSObject


#pragma mark Properties

@property (nonatomic, strong) NSString *identifier;

// Stores whether this request is currently
// processed by connection or not
@property (nonatomic, assign) BOOL processing;


#pragma mark - Instance methods

/**
 * Return resouce path which will be used
 * in serialized HTTP header to specify
 * requested resource path:
 * GET {resource_path} HTTP/1.1
 */
- (NSString *)resourcePath;

/**
 * Retrieve reference on write buffer
 * which will be used to send serialized
 * response via socket
 */
- (PNWriteBuffer *)buffer;

#pragma mark -


@end
