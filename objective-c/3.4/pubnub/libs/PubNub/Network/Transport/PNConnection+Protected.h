//
//  PNConnection+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#import "PNConnection.h"
#import "PNBaseRequest+Protected.h"


#pragma mark - Structures

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