#include "JSONPort.h"
#include <Foundation/NSStream.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSNull.h>

#include "ByteStream.h"
#include "JSONExtensions.h"


@interface JSONPort (PrivateMethods)

- (void) closeConnection;

- (BOOL) sendMessage: (NSDictionary *) msg;

@end


#define ALLOC_REQUEST( met, par, rid )                      \
    [[NSDictionary alloc] initWithObjectsAndKeys:           \
    (met), @"method", (par), @"params", (rid), @"id", 0]

#define ALLOC_RESPONSE( res, err, rid )                     \
    [[NSDictionary alloc] initWithObjectsAndKeys:           \
    (res), @"result", (err), @"error", (rid), @"id", 0]

#define SET_ERROR( fmt, args... )                                   \
    do {                                                            \
        [_error release];                                           \
        _error = [[NSString alloc] initWithFormat: fmt , ##args];   \
    } while (0)

#define SET_ERROR_AND_FAIL( fmt, args... )                          \
    do {                                                            \
        [_error release];                                           \
        _error = [[NSString alloc] initWithFormat: fmt , ##args];   \
        return 0;                                                   \
    } while (0)


@implementation JSONPort

- (id) initWithHost: (NSHost *) host port: (int) port
{
    NSInputStream * is;
    NSOutputStream * os;
    [NSStream getStreamsToHost: host port: port
              inputStream: &is outputStream: &os ];

    return [self initWithInputStream: is outputStream: os];
}

- (id) initWithLocalSocket: (NSString *) path
{
    NSInputStream * is;
    NSOutputStream * os;
    [NSStream getLocalStreamsToPath: path
              inputStream: &is outputStream: &os ];

    return [self initWithInputStream: is outputStream: os];
}

- (id) initWithInputStream: (NSInputStream *) iStream
              outputStream: (NSOutputStream *) oStream
{
    if ( (self = [super init]) == 0 )
        return 0;
    
    _is = 0;
    _os = 0;
    _error = 0;

    _NullClass = [NSNull class];
    _null = [NSNull null];

    if ( ! (iStream && oStream) )
    {
        [self release];
        return 0;
    }

    _is = [[ByteIStream alloc] initWithNSIStream: iStream ];
    if ( ! _is )
    {
        [self release];
        return 0;
    }

    _os = [[ByteOStream alloc] initWithNSOStream: oStream ];
    if ( ! _os )
    {
        [self release];
        return 0;
    }
    
    return self;
}

- (id) initWithDuplexFD: (int) fd
{
    return [self initWithInputFD: fd outputFD: fd];
}

- (id) initWithInputFD: (int) fdin outputFD: (int) fdout
{
    if ( (self = [super init]) == 0 )
        return 0;
    
    _is = 0;
    _os = 0;
    _error = 0;

    _NullClass = [NSNull class];
    _null = [NSNull null];

    _is = [[ByteIStream alloc] initWithFD: fdin ];
    if ( ! _is )
    {
        [self release];
        return 0;
    }

    _os = [[ByteOStream alloc] initWithFD: fdout ];
    if ( ! _os )
    {
        [self release];
        return 0;
    }

    return self;
}

- (void) dealloc
{
    [_is release];
    [_os release];

    [_error release];
    
    [super dealloc];
}

- (NSString *) lastError
{
    return _error;
}

- (void) closeConnection
{
    [_os release];
    [_is release];
    _is = nil;
    _os = nil;
}

- (NSDictionary *) getRetainedMessage
{
    if ( ! (_is && _os)  )
        SET_ERROR_AND_FAIL( @"No connection" );

    NSString * parseErr = 0;
    NSMutableDictionary * msg =
        [[NSDictionary alloc] initFromJSONStream: _is error: &parseErr];

    if ( ! msg )
    {
        if ( parseErr )
        {
            SET_ERROR( @"Cannot parse message: %@. Closing connection.",
                      parseErr );

            [self sendError: _error rid: _null];
        }
        else
        {
            // parseErr == 0 means end of input stream.
            [_error release];
            _error = 0;
        }

        [self closeConnection];
        return 0;
    }

    // Check that the message has the right format.
    // Here we do not do rigorous check and allow for missing keys.
    // We treat them as the ones with null values. 

    NSString * error = 0;

    id rid = [msg rid];
    id met = [msg method];
    id res = [msg result];
    id err = [msg error];
    
    if ( met )
    {
        // request

        id pms = [msg params];
        
        if ( res )
            error = @"both \"method\" and \"result\" keys exit";
        else if (err)
            error = @"both \"method\" and \"error\" keys exist";
        else if ( ! [met isKindOfClass: [NSString class]] )
            error = @"method is not a string";
        else if ( [met isEqualToString: @""] )
            error = @"method is empty string";
        else if ( pms && ! [pms isKindOfClass: [NSArray class]] )
            error = @"params is not an array or null";

    }
    else
    {
        // response

        if ( !rid )
            error = @"response without \"id\"";
        else if ( !res && !err )
            error = @"both result and error set to null";
        // if both are not null, assume that error takes priority
    }

    if ( error )
    {
        SET_ERROR( @"Protocol error: %@.", error );
        [msg release];
        msg = 0;

        // Send the error back to the client if the client expects
        // the response, i.e. if met is set and rid is non-null.
        // Do we really need this ??

        if ( met && rid )
        {
            NSString * protocolError = _error;
            [protocolError retain];
            
            BOOL sendStatus = [self sendError: _error rid: rid];
            NSString * sendError = _error;
            [sendError retain];

            if ( sendStatus )
                SET_ERROR( @"%@ Error response sent back.", protocolError );
            else
                SET_ERROR( @"%@ An attempt to send the error back failed: %@",
                           protocolError, sendError);

            [sendError release];
            [protocolError release];
        }
    }
    
    return msg;
}

- (BOOL) sendMessage: (NSDictionary *) msg
{
    if ( ! _os )
        SET_ERROR_AND_FAIL( @"sendMessage: No connection" );
    
    BOOL status = [msg writeToJSONStream: _os];

    if ( status )
        status = (str_flush( _os ) == 0);

    if ( ! status )
        SET_ERROR( @"sendMessage: writeToJSONStream failed");

    return status;
}

- (BOOL) sendResult: (id) result rid: (id) rid
{
    if ( ! result )
        SET_ERROR_AND_FAIL( @"sendResult: result is required" );
    if ( ! rid )
        SET_ERROR_AND_FAIL( @"sendResult: requestID is required" );
    if ( [rid isKindOfClass: _NullClass] )
        SET_ERROR_AND_FAIL( @"sendResult: requiestID cannot be NSNull" );

    NSDictionary * msg = ALLOC_RESPONSE( result, _null, rid );
    if ( ! msg )
        SET_ERROR_AND_FAIL( @"sendResult: cannot allocate memory" );
    
    BOOL status =  [self sendMessage: msg];

    [msg release];
    return status;
}

- (BOOL) sendError: (id) error rid: (id) rid
{
    if ( ! error )
        SET_ERROR_AND_FAIL( @"sendError: error is required" );
    if ( ! rid )
        SET_ERROR_AND_FAIL( @"sendError: requestID is required" );
    if ( [rid isKindOfClass: _NullClass] )
        SET_ERROR_AND_FAIL( @"sendError: requiestID cannot be NSNull" );

    NSDictionary * msg = ALLOC_RESPONSE( _null, error, rid );
    if ( ! msg )
        SET_ERROR_AND_FAIL( @"sendError: cannot allocate memory" );
    
    BOOL status =  [self sendMessage: msg];

    [msg release];
    return status;
}

- (BOOL) sendNotification: (NSString *) method params: (NSArray *) params
{
    return [self sendMethod: method params: params rid: _null];
}

- (BOOL) sendMethod: (NSString *) method params: (NSArray *) params
                 rid: (id) rid
{
    if ( ! method )
        SET_ERROR_AND_FAIL( @"sendMethod: method is required" );

    NSDictionary * msg =
        ALLOC_REQUEST( method, params ? (id)params : _null, rid ? rid : _null);
    if ( ! msg )
        SET_ERROR_AND_FAIL( @"sendMethod: cannot allocate memory" );

    BOOL status =  [self sendMessage: msg];

    [msg release];
    return status;
}


/**
 * Makes blocking method call: sends method and waits for response.
 * Returns retained dictionary that contains response or 0 on error.
 */
- (id) makeMethodCall: (NSString *) method params: (NSArray *) params
{
    id rid = [self createRetainedRid];
    if ( ! rid || [rid isKindOfClass: _NullClass] )
        SET_ERROR_AND_FAIL( @"makeMethodCall: request ID cannot be null" );

    BOOL status = [self sendMethod: method params: params rid: rid];

    NSDictionary * response = 0;

    if ( status == NO )
        goto communicationFailure;

    // Get response back from the server.
    // BUG: we need to implement timeout.

    response = [self getRetainedMessage];
    if ( ! response )
    {
        if ( ! _error )
            SET_ERROR( @"unexpected end of stream while waiting for response" );
        goto communicationFailure;
    }
    
    if ( ! [response objectForKey: @"result"] )
    {
        SET_ERROR( @"wrong message type: request instead of response" );
        goto communicationFailure;
    }

    if ( ! [rid isEqual: [response rid]] )
    {
        SET_ERROR( @"response with wrong ID" );
        goto communicationFailure;
    }

    [rid release];
    return response;

communicationFailure:
    [response release];
    [rid release];
    return 0;
}

- (id) createRetainedRid
{
    return [[NSNumber alloc] initWithInt: 1];
}

@end // JSONPort
