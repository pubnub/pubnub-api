//
//  PNConnection+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/10/12.
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