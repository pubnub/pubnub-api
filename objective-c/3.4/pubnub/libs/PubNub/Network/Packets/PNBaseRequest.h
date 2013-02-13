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

// Short identifier is hash from original
// one which will be used to identify request
// from response JSONP callback method name
@property (nonatomic, strong) NSString *shortIdentifier;

// Stores whether this request is currently
// processed by connection or not
@property (nonatomic, assign) BOOL processing;

// Stores whether this request already prcessed
// or not
@property (nonatomic, assign) BOOL processed;

// Stores whether leave request was sent to subscribe
// on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;


#pragma mark - Instance methods

/**
 * Retrieve default configuration for timeout value
 * which is used for non-subscription requests
 */
- (NSTimeInterval)timeout;

/**
 * Returns callback method name which should be
 * used to identify this request's response
 */
- (NSString *)callbackMethodName;

/**
 * Return resource path which will be used
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
