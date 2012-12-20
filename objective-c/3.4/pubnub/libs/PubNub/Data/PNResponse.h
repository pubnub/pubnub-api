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

@property (nonatomic, readonly, strong) NSData *content;
@property (nonatomic, readonly, assign) NSUInteger statusCode;
@property (nonatomic, readonly, assign) NSUInteger size;


#pragma mark - Class methods

/**
 * Retrieve instance which will hold information about
 * HTTP response body and size of whole response
 * (including HTTP headers)
 */
+ (PNResponse *)responseWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode;


#pragma mark - Instance methods

/**
 * Intialize response instance with response
 * body content data, response size and status
 * code (HTTP status code)
 */
- (id)initWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode;

#pragma mark -


@end
