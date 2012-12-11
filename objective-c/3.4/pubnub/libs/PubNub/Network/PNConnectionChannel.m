//
//  PNConnectionChannel.m
//  pubnub
//
//  Connection channel is intermediate class
//  between transport network layer and other
//  library classes.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNConnectionChannel.h"
#import "PNConnection+Protected.h"
#import "PNConnection.h"


#pragma mark Private interface methods

@interface PNConnectionChannel ()


#pragma mark - Properties

// Stores reference on connection which is used
// as transport layer to send messages to the
// PubNub service
@property (nonatomic, strong) PNConnection *connection;


@end


#pragma mark Public interface methods

@implementation PNConnectionChannel


#pragma mark - Class methods

+ (PNConnectionChannel *)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType {
    
    return [[[self class] alloc] initWithType:connectionChannelType];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType {
    
    // Check whether intialization was successful or not
    if((self = [super init])) {
        
        // Retrieve connection idetifier based on connection channel type
        NSString *connectionIdentifier = PNConnectionIdentifiers.messagingConnection;
        if (connectionChannelType == PNConnectionChannelService) {
            
            connectionIdentifier = PNConnectionIdentifiers.serviceConnection;
        }
        
        self.connection = [PNConnection connectionWithIdentifier:connectionIdentifier];
        self.connection.delegate = self;
    }
    
    
    return self;
}

#pragma mark -


@end
