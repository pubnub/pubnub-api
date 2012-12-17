//
//  PNConnectionChannel+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/11/12.
//
//


#pragma mark Connection channel types

// This enum represents list of available connection
// channel types
typedef enum _PNConnectionChannelType {
    
    // Channel used to communicate with PubNub messaging
    // service:
    //   - subscription
    //   - presence
    PNConnectionChannelMessagin,
    
    // Channel used for sending other requests like:
    //   - leave
    //   - history
    //   - time token
    //   - latency meter
    //   - list of participants
    PNConnectionChannelService
} PNConnectionChannelType;

// This enum represents list of available connection
// states
typedef enum _PNConnectionChannelState {
    
    // Channel was just created (no connection to
    // PubNub services)
    PNConnectionChannelStateCreated,
    
    // Channel trying to establish connection
    // to PubNub services
    PNConnectionChannelStateConnecting,
    
    // Channel is ready for work (connections
    // established and requests queue is ready)
    PNConnectionChannelStateConnected,
    
    // Channel is disconnecting on user request
    // (for example: leave request for all channels)
    PNConnectionChannelStateDisconnecting,
    
    // Channel is disconnecting on because of error
    PNConnectionChannelStateDisconnectingOnError,
    
    // Channel is ready, but was disconnected and
    // waiting command for connection (or was unable
    // to connect during intialization)
    // All requests queue is alive (if they wasn't
    // flushed by user)
    PNConnectionChannelStateDisconnected
} PNConnectionChannelState;

#pragma mark -