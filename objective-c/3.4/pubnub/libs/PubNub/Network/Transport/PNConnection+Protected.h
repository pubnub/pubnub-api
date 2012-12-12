//
//  PNConnection+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/10/12.
//
//


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

static struct PNConnectionIdentifiersStruct PNConnectionIdentifiers = {
    
    .messagingConnection = @"PNMessaginConnectionIdentifier",
    .serviceConnection = @"PNServiceConnectionIdentifier"
};

// Structure describes error notification body
struct PNConnectionErrorNotificationBodyStruct {
    
    // Used to store error message
    __unsafe_unretained NSString *error;
};

static struct PNConnectionErrorNotificationBodyStruct PNConnectionErrorNotificationBody = {
    
    .error = @"errorObject"
};


#pragma mark - Notifications

// List of notifications which is used to inform observation
// center about connection state change
extern NSString * const kPNConnectionDidConnectNotication;
extern NSString * const kPNConnectionDidDisconnectNotication;
extern NSString * const kPNConnectionDidDisconnectWithErrorNotication;
extern NSString * const kPNConnectionErrorNotification;

#pragma mark -