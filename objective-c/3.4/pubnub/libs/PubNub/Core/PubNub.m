//
//  PubNub.m
//  pubnub
//
//  This is base and main class which is
//  responsible for communication with
//  PubNub services and handle all events
//  and notifications.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PubNub.h"
#import "PubNub+Protected.h"


#pragma mark Static

// Stores reference on singleton PubNub instance
static PubNub *_sharedInstance = nil;


#pragma mark - Private interface methods

@interface PubNub ()


#pragma mark - Class methods

+ (PubNub *)sharedInstance;


@end


#pragma mark - Public interface methods

@implementation PubNub


#pragma mark - Class methods

+ (PubNub *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
    
    
    return _sharedInstance;
}

+ (void)connect {
    
    NSAssert([self sharedInstance].configuration==nil, @"ERROR: PubNub configuration is required before connection.");
}

+ (void)setConfiguration:(PNConfiguration *)configuration {
    
    NSAssert1([configuration isValid], @"ERROR: Wrong or incompleted configuration has been passed to PubNumb client: %@",
              configuration);
    
    if (![self sharedInstance].isInitialized) {
        
        [[self sharedInstance] setConfiguration:configuration];
    }
    else {
        // TODO: PERFORM HARD RESET
    }
}

+ (void)setClientIdentifier:(NSString *)identifier {
    
    // Check whether identifier has beeen changed since last
    // method call or not
    if([self sharedInstance].isInitialized) {
        
        NSString *clientIdentifier = [self sharedInstance].clientIdentifier;
        if(clientIdentifier != nil && ![clientIdentifier isEqualToString:identifier]) {
            
            // TODO: SEND LEAVE EVENT TO THE PRESENCE API
            //       AND RE-SUBSCRIBE TO SPECIFIED CHANNELS
        }
    }
    else {
        
        [self sharedInstance].clientIdentifier = identifier;
    }
}

+ (NSString *)clientIdentifier {
    
    NSString *identifier = [self sharedInstance].clientIdentifier;
    if (identifier == nil) {
        
        
    }
    
    
    return [self sharedInstance].clientIdentifier;
}

#pragma mark -


@end
