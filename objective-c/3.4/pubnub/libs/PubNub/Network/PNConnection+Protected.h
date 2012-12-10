//
//  PNConnection+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#import "PNConnection.h"


@interface PNConnection (Protected)


#pragma mark Structures

// Structure describes list of available
// connection identifiers
struct PNConnectionIdentifiersStruct {
    
    // Used to identify connection which is used
    // for: subscriptions and presence observing
    __unsafe_unretained NSString *messagingConnection;
    
    // Used for another set of calls to the PubNub
    // service
    __unsafe_unretained NSString *serviceConnection;
};

// Structure describes error notification body
struct PNConnectionErrorNotificationBodyStruct {
    
    // Used to store error message
    __unsafe_unretained NSString *error;
};


#pragma mark - Notifications

// List of notifications which is used to inform observation
// center about connection state change
extern NSString * const kPNConnectionDidConnectNotication;
extern NSString * const kPNConnectionDidDisconnectNotication;
extern NSString * const kPNConnectionDidDisconnectWithErrorNotication;
extern NSString * const kPNConnectionErrorNotification;

#pragma mark -


@end
