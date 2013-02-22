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

// Sent when PubNub client got some error
// during life time
static NSString * const kPNClientErrorNotification = @"PNClientErrorNotification";

// Sent when PubNub client connected to remote
// PubNub services (origin host name will be passed
// in userInfo like plain NSString)
static NSString * const kPNClientDidConnectToOriginNotification = @"PNClientDidConnectToOriginNotification";

// Sent when PubNub client is about to connect to remote
// PubNub services (origin host name will be passed
// in userInfo like plain NSString)
static NSString * const kPNClientWillConnectToOriginNotification = @"PNClientWillConnectToOriginNotification";

// Sent when PubNub client disconnected from remote
// PubNub services (origin host name will be passed
// in userInfo like plain NSString)
static NSString * const kPNClientDidDisconnectFromOriginNotification = @"PNClientDidDisconnectFromOriginNotification";

// Sent when PubNub client stumbled on connection
// issues and closed connection or because it was
// unable to setup initial connection (error will
// be passed in userInfo like PNError instance)
static NSString * const kPNClientConnectionDidFailWithErrorNotification = @"PNClientConnectionDidFailWithErrorNotification";

// Sent when PubNub client was able to subscribe on
// specified channel(s) (channel(s) will be passed
// in userInfo like plain NSArray)
static NSString * const kPNClientSubscriptionDidCompleteNotification = @"PNClientSubscriptionDidCompleteNotification";

// Sent when PubNub client is about to restore subscription on
// specified channel(s) (channel(s) will be passed
// in userInfo like plain NSArray)
static NSString * const kPNClientSubscriptionWillRestoreNotification = @"PNClientSubscriptionWillRestoreNotification";

// Sent when PubNub client was able to restore subscription on
// specified channel(s) (channel(s) will be passed
// in userInfo like plain NSArray)
static NSString * const kPNClientSubscriptionDidRestoreNotification = @"PNClientSubscriptionDidRestoreNotification";

// Sent when PubNub client was unable to subscribe on
// specified channel(s) (error will be passed in
// userInfo and channel(s) will be passed in associatedObject
// like NSArray)
static NSString * const kPNClientSubscriptionDidFailNotification = @"PNClientSubscriptionDidFailNotification";

// Sent when PubNub client successfully unsubscribed
// from specified channel(s) (channel(s) will be
// passed in userInfo like plain NSArray)
static NSString * const kPNClientUnsubscriptionDidCompleteNotification = @"PNClientUnsubscriptionDidCompleteNotification";

// Sent when PubNub client failed to unsubscribe
// from specified channel(s) (error will be passed in
// userInfo and channel(s) will be passed in associatedObject
// like NSArray)
static NSString * const kPNClientUnsubscriptionDidFailNotification = @"PNClientUnsubscriptionDidFailNotification";

// Sent when PubNub client received time token
// from PubNub service (time token value will be passed in
// user info like plain NSString)
static NSString * const kPNClientDidReceiveTimeTokenNotification = @"PNClientDidReceiveTimeTokenNotification";

// Sent when PubNub client failed to receive time
// token from PubNub service (error will be passed in
// userInfo)
static NSString * const kPNClientDidFailTimeTokenReceiveNotification = @"PNClientDidFailTimeTokenReceiveNotification";

// Sent when PubNub client is about to sent message
// to PubNub remote service (message object will be
// passed in userInfo like PNMessage object)
static NSString * const kPNClientWillSendMessageNotification = @"PNClientWillSendMessageNotification";

// Sent when PubNub client did send message to PubNub
// remote service (message object will be
// passed in userInfo like PNMessage object)
static NSString * const kPNClientDidSendMessageNotification = @"PNClientDidSendMessageNotification";

// Send when PubNub client failed to send message to
// PubNub service (error will be passed in userInfo
// like PNError and PNMessage on which error is occurred
// will be passed as property of PNError "associatedObject")
static NSString * const kPNClientMessageSendingDidFailNotification = @"PNClientMessageSendingDidFailNotification";

// Sent when PubNub client received new message from
// Pubnub service on subscribed channels (received message
// will be passed in userInfo like PNMessage instance)
static NSString * const kPNClientDidReceiveMessageNotification = @"PNClientDidReceiveMessageNotification";

// Sent when PubNub client received new presence event from
// PubNub service on channels on which presence observing
// is enable (presence event object will be passed with
// userInfo in PNPresenceEvent object instance)
static NSString * const kPNClientDidReceivePresenceEventNotification = @"PNClientDidReceivePresenceEventNotification";

// Sent when PubNub client successfully downloaded history
// messages for specified channel (history object will be
// passed in userInfo as PNMessageHistory instance)
static NSString * const kPNClientDidReceiveMessagesHistoryNotification = @"PNClientDidReceiveMessagesHistoryNotification";

// Sent when PubNub client failed to download messages history
// for specified channel (error message will be passed in
// userInfo as PNError and channel for which client can't
// download history will be passed in error's "associatedObject")
static NSString * const kPNClientHistoryDownloadFailedWithErrorNotification = @"PNClientHistoryDownloadFailedWithErrorNotification";

// Sent when PubNub client successfully downloaded 'here now'
// (participants list) request for specific channel (
// here now object will be passed in userInfo as PNHereNow instance)
static NSString * const kPNClientDidReceiveParticipantsListNotification = @"PNClientDidReceiveParticipantsListNotification";

// Sent when PubNub client failed to download 'here now'
// (participants list) from remote service
static NSString * const kPNClientParticipantsListDownloadFailedWithErrorNotification=@"PNClientParticipantsListDownloadFailedWithErrorNotification";

#endif
