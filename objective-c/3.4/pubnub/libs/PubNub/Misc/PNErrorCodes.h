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


#pragma mark - Client error codes

// PubNub client find out that it wasn't fully
// configured and can't process his work
static NSInteger const kPNClientConfigurationError = 100;

// PubNub client tried to connect while it already
// has opened connection to PubNub services
static NSInteger const kPNClientConnectWhileConnected = 101;

// PubNub client failed to connect to PubNub services
// because internet went down
static NSInteger const kPNClientConnectionFailedOnInternetFailure = 102;


#pragma mark - Connection (transport layer) error codes

// Was unable to configure connection because of some
// errors
static NSInteger const kPNConnectionErrorOnSetup = 103;