//
//  PNWriteBuffer.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/14/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Static

// Stores reference on maximum write TCP
// packet size which will be sent over the
// socket (Default: 4kb)
static NSUInteger const kPNWriteBufferSize = 4096;


#pragma mark - Class forward

@class PNBaseRequest;


@interface PNWriteBuffer : NSObject


#pragma mark - Properties

// Stores reference on object which is required
// this buffer using it's identifier
@property (nonatomic, copy) NSString *requestIdentifier;

// Stores reference on how long packet payload which should
// be sent over the socket
@property (nonatomic, readonly) CFIndex length;

// Stores offest for data which already sent via socket
@property (nonatomic, assign) CFIndex offset;


#pragma mark - Class methods

/**
 * Create write buffer instance using specified request
 */
+ (PNWriteBuffer *)writeBufferForRequest:(PNBaseRequest *)request;


#pragma mark - Instance methods

/**
 * Initiate write buffer for provided request
 */
- (id)initWithRequest:(PNBaseRequest *)request;

/**
 * Return whether buffer has any data which can be 
 * sent (calculations based on offset and total length
 */
- (BOOL)hasData;

/**
 * Retrieve reference on buffer which take into
 * account number of sent bytes
 */
- (UInt8 *)buffer;

#pragma mark -


@end
