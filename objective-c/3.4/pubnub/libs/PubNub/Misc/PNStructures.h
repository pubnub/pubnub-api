//
//  PNStructures.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/6/12.
//
//


#pragma mark Class forward

@class PNError, PNMessage;


#ifndef PNStructures_h
#define PNStructures_h

typedef void (^PNClientConnectionSuccessBlock)(NSString *);
typedef void (^PNClientConnectionFailureBlock)(PNError *);
typedef void (^PNClientConnectionStateChangeBlock)(NSString *, BOOL, PNError *);
typedef void (^PNClientChannelSubscriptionHandlerBlock)(NSArray *, BOOL, PNError *);
typedef void (^PNClientChannelUnsubscriptionHandlerBlock)(NSArray *, PNError *);
typedef void (^PNClientTimeTokenReceivingCompleteBlock)(NSString *, PNError *);
typedef void (^PNClientMessageSendingCompletionBlock)(PNMessage *, BOOL, PNError *);


// This enum represent possible stream
// states
typedef enum _PNSocketStreamState {
    
    // Stream not configured
    PNSocketStreamNotConfigured,
    
    // Stream configured by connection manager
    PNSocketStreamReady,
    
    // Stream is connecting at this moment
    PNSocketStreamConnecting,
    
    // Stream connected to the origin server
    // over socket (secure if configured)
    PNSocketStreamConnected,
    
    // Stream failure (not connected) because
    // of error
    PNSocketStreamError
} PNSocketStreamState;


// This enum represents list of possible
// presence event types
typedef enum _PNPresenceEventType {
    
    // New person joined to the channel
    PNPresenceEventJoin,
    
    // Person leaved channel by its own
    PNPresenceEventLeave,
    
    // Person leaved channel because of timeout
    PNPresenceEventTimeout
} PNPresenceEventType;

#endif
