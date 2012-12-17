//
//  PNErrorCodes.h
//  pubnub
//
//  Describes all available error codes
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

// PubNub client find out that it wasn't fully
// configured and can't process his work
static NSInteger const kPNClientConfigurationError = 100;

// PubNub client tried to connect while it already
// has opened connection to PubNub services
static NSInteger const kPNClientConnectWhileConnected = 101;

// PubNub client failed to connect to PubNub services
// because internet went down
static NSInteger const kPNClientConnectionFailedOnInternetFailure = 102;

// PubNub client initialization failure
// Possible reasons are:
//   - identifier already taken by someone else
//   - request time out
//   - response parsing error
static NSInteger const kPNInitializationErrorCode = 103;