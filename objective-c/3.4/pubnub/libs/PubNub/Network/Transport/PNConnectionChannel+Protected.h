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
    //   - leave
    PNConnectionChannelMessagin,
    
    // Channel used for sending other requests like:
    //   - history
    //   - time token
    //   - latency meeter
    //   - list of participants
    PNConnectionChannelService
} PNConnectionChannelType;

#pragma mark -