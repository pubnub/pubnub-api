//
//  PNStructures.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/6/12.
//
//


#pragma mark Class forward

@class PNError, PNMessage, PNPresenceEvent, PNChannel;


#ifndef PNStructures_h
#define PNStructures_h

// This enum represents possible message
// processing states
typedef enum _PNMessageState {

    // Message was scheduled for processing.
    // "processingData" field will contain message
    // instance which was scheduled for processing
    PNMessageSending,

    // Message was successfully sent to the
    // PubNub service.
    // "processingData" field will contain message
    // instance which was sent for processing
    PNMessageSent,

    // PubNub client failed to send message because
    // of some reasons.
    // "processingData" field will contain error instance
    // which will describe error which occurred during
    // message processing
    PNMessageSendingError
} PNMessageState;


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

// This enum represent list of possible
// events which can occurre during requests
// execution
typedef enum _PNOperationResultEvent {

   // Stores unknown event
   PNOperationResultUnknown,
   PNOperationResultLeave = PNPresenceEventLeave
} PNOperationResultEvent;


typedef void (^PNClientConnectionSuccessBlock)(NSString *);
typedef void (^PNClientConnectionFailureBlock)(PNError *);
typedef void (^PNClientConnectionStateChangeBlock)(NSString *, BOOL, PNError *);
typedef void (^PNClientChannelSubscriptionHandlerBlock)(NSArray *, BOOL, PNError *);
typedef void (^PNClientChannelUnsubscriptionHandlerBlock)(NSArray *, PNError *);
typedef void (^PNClientTimeTokenReceivingCompleteBlock)(NSNumber *, PNError *);
typedef void (^PNClientMessageProcessingBlock)(PNMessageState, id);
typedef void (^PNClientMessageHandlingBlock)(PNMessage *);
typedef void (^PNClientHistoryLoadHandlingBlock)(NSArray *, PNChannel *, NSDate *, NSDate *, PNError *);
typedef void (^PNClientParticipantsHandlingBlock)(NSArray *, PNChannel *, PNError *);
typedef void (^PNClientPresenceEventHandlingBlock)(PNPresenceEvent *);

#endif
