//
//  PNWriteBuffer.h
//  pubnub
//
//  Write buffer is objects which is used by
//  connection instance to fetch portion of
//  data which should be send and also used
//  to check whether full packet has been
//  sent or not.
//
//
//  Created by Sergey Mamontov.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNBaseRequest;


@interface PNWriteBuffer : NSObject


#pragma mark - Properties

// Stores reference on object which is required
// this buffer using it's identifier
@property (nonatomic, copy) NSString *requestIdentifier;

// Stores whether buffer sending initialized or not
// (write buffer bytes readout started)
@property  (nonatomic, assign, getter = isSendingBytes) BOOL sendingBytes;

// Stores reference on how long packet payload which should
// be sent over the socket
@property (nonatomic, readonly, assign) CFIndex length;

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
 * Returns whether buffer already sent some portion
 * of data for processing or not
 */
- (BOOL)isPartialDataSent;

/**
 * Retrieve reference on buffer which take into
 * account number of sent bytes
 */
- (UInt8 *)buffer;

/**
 * Retrieve size of the buffer which should be
 * used when writting content into sokect stream
 */
- (CFIndex)bufferLength;

#pragma mark -


@end
