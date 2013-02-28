//
//  PNResponse.h
//  pubnub
//
//  This class instance designed to store
//  binary response from backend with some
//  additional information which will help
//  to understand some metrics.
//
//
//  Created by Sergey Mamontov on 12/20/12.
//
//

#import <Foundation/Foundation.h>


@interface PNResponse : NSObject


#pragma mark Properties

// Stores binary response from PubNub services
@property (nonatomic, readonly, strong) NSData *content;

// Stores HTTP status code which was returned
// on sent request
@property (nonatomic, readonly, assign) NSUInteger statusCode;

// Stores response size (including HTTP header
// fields)
@property (nonatomic, readonly, assign) NSUInteger size;

// Stores reference on error object which will hold
// any information about parsing error
@property (nonatomic, readonly, strong) PNError *error;

// Stores reference on request small identifier
// hash which will be used to find request
// which sent this request
@property (nonatomic, readonly, copy) NSString *requestIdentifier;

// Stores reference on callback function name
// which will be returned in JSONP response
@property (nonatomic, readonly, copy) NSString *callbackMethod;

// Stores reference on response body object
// (array in most of cases)
@property (nonatomic, readonly, strong) id response;


#pragma mark - Class methods

/**
 * Retrieve instance which will hold information about
 * HTTP response body and size of whole response
 * (including HTTP headers)
 */
+ (PNResponse *)responseWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode;


#pragma mark - Instance methods

/**
 * Initialize response instance with response
 * body content data, response size and status
 * code (HTTP status code)
 */
- (id)initWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode;

/**
 * Return whether request has been processed correctly or not
 */
- (BOOL)isCorrectResponse;

#pragma mark -


@end
