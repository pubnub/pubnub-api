#ifndef _INCLUDED_JSONPort_h
#define _INCLUDED_JSONPort_h

// JSONPort - end point of JSON_RPC connection.

#include <Foundation/NSObject.h>
#include <Foundation/NSDictionary.h>

@class NSArray;
@class NSHost;
@class NSString;
@class NSInputStream;
@class NSOutputStream;
@class ByteIStream;
@class ByteOStream;

@interface NSDictionary (JSONRPC)
- (NSString *) method;
- (NSArray *) params;
- (id) rid;
- (id) result;
- (id) error;
@end


@interface JSONPort : NSObject
{
    ByteIStream *   _is;
    ByteOStream *   _os;
    NSString *      _error;

    Class           _NullClass;
    id              _null;
}

/* Those two methods seems to call accept(), therefore they apply to
 * cliesnt side sockets.
 */

- (id) initWithHost: (NSHost *) host port: (int) port;
- (id) initWithLocalSocket: (NSString *) path;

/* These init method works for both client and server side sockets. */

- (id) initWithInputStream: (NSInputStream *) iStream
              outputStream: (NSOutputStream *) oStream;
- (id) initWithInputFD: (int) fdin outputFD: (int) fdout;
- (id) initWithDuplexFD: (int) fd;


/**
 * Send method request or notification (requestID is nil).
 * Does not wait for response. On failure returns NO and sets the error.
 */
- (BOOL) sendMethod: (NSString *) method params: (NSArray *) params
                rid: (id) rid;

/**
 * Convenience method for -sendMethod:params:rid: with null rid.
 *  Null rid means the caller does not expect response.
 */
- (BOOL) sendNotification: (NSString *) method params: (NSArray *) params;

/**
 * These methods return NO on failure and set the error.
 */
- (BOOL) sendResult: (id) result rid: (id) requestID;
- (BOOL) sendError: (id) error rid: (id) requestID;

/**
 * On success returns retained dictionary that is a valid request
 * or response. On error returns 0 and sets the error.
 */
- (NSDictionary *) getRetainedMessage;

/**
 * Makes blocking method call: sends method and waits for response.
 * Returns retained dictionary that contains response or 0 on error.
 */
- (id) makeMethodCall: (NSString *) method params: (NSArray *) params;

/**
 * Creates retained request ID object. Override this method to create RIDs
 * that suit your purpouse, RID cannot be null os NSNull. Current implementation
 * returns NSNumber initialized with 1. 
 */
- (id) createRetainedRid;

- (NSString *) lastError;

@end

#endif // _INCLUDED_JSONPort_h
