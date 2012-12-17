//
//  PNNotifications.h
//  pubnub
//
//  This header stores list of all notification
//  names which will be used across PubNub client
//  library.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#ifndef PNNotifications_h
#define PNNotifications_h

// Sent when PubNub client connected to remote
// PubNub services (origin host name will be passed
// in userInfo like plain NSString)
static NSString * const kPNClientDidConnectToOriginNotification = @"PNClientDidConnectToOriginNotification";

// Sent when PubNub client disconnected from remote
// PubNub services (origin host name will be passed
// in userInfo like plain NSString)
static NSString * const kPNClientDidDisconnectFromOriginNotification = @"PNClientDidDisconnectFromOriginNotification";

// Sent when PubNub client sumbled on connection
// issues and closed connection or because it was
// unable to setup initial connection (error will
// be passed in userInfo like PNError instance)
static NSString * const kPNClientConnectionDidFailWithErrorNotification = @"PNClientConnectionDidFailWithErrorNotification";

// Sent when PubNub client was unable to subscribe for
// specified channel (channel name will be passed
// in userInfo like plain NSString)
static NSString * const kPNClientSubscriptionDidFailNotification = @"PNClientSubscriptionDidFailNotification";

#endif
