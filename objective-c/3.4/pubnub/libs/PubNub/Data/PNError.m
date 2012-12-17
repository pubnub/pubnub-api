//
//  PNError.m
//  pubnub
//
//  Class which will be used to describe internal
//  PubNub client errors.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import "PNError.h"


#pragma mark Data keys (internal)

// This structure describes keys used to store
// data inside error's user info dictionary
struct PNErrorInfoKeysStruct {
  
    __unsafe_unretained NSString *channelName;
};

static struct PNErrorInfoKeysStruct PNErrorInfoKeys = {
    
    .channelName = @"channelName"
};


#pragma mark - Private interface methods

@interface PNError ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *errorMessage;


#pragma mark - Instance methods

/**
 * Returns error domain which will be based on 
 * error code
 */
- (NSString *)domainForError:(NSInteger)errorCode;

@end


#pragma mark - Public interface methods

@implementation PNError


#pragma mark - Class methods

+ (PNError *)errorWithCode:(NSInteger)errorCode {
    
    return [self errorWithCode:errorCode channel:nil];
}

+ (PNError *)errorWithCode:(NSInteger)errorCode channel:(NSString *)channelName {
    
    return [self errorWithMessage:nil code:errorCode channel:channelName];
}

+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode {
    
    return [self errorWithMessage:errorMessage code:errorCode channel:nil];
}

+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode channel:(NSString *)channelName {
    
    return [[[self class] alloc] initWithMessage:errorMessage code:errorCode channel:channelName];
}


#pragma mark - Instance methods

- (id)initWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode channel:(NSString *)channelName {
    
    // Check whether initialization successful or not
    NSDictionary *userInfo = channelName?@{PNErrorInfoKeys.channelName:channelName}:nil;
    if((self = [super initWithDomain:[self domainForError:errorCode] code:errorCode userInfo:userInfo])) {
        
        self.errorMessage = errorMessage;
    }
        
        
    return self;
}

- (NSString *)localizedDescription {
    
    NSString *errorDescription = self.errorMessage;
    
    // Check whether error message was specified or not
    if (errorDescription == nil) {
        
        switch (self.code) {
                
            case kPNClientConfigurationError:
                
                errorDescription = @"Incomplete PubNub client configuration";
                break;
            case kPNClientConnectWhileConnected:
                
                errorDescription = @"PubNub client already connected to origin";
                break;
            case kPNClientConnectionFailedOnInternetFailure:
                
                errorDescription = @"PubNub client connection failed";
                break;
            default:
                break;
        }
    }
    
    
    return errorDescription;
}

- (NSString *)localizedFailureReason {
    
    NSString *failureReason = nil;
    
    switch (self.code) {
            
        case kPNClientConfigurationError:
            
            failureReason = @"One of required configuration field is empty:\n- publish key\n- subscribe key\n- secret key";
            break;
        case kPNClientConnectWhileConnected:
            
            failureReason = @"Looks like client tried to connecte to remote PubNub service while already has connection";
            break;
        case kPNClientConnectionFailedOnInternetFailure:
            
            failureReason = @"Looks like client lost connection while trying to connect to remote PubNub service";
            break;
            
        default:
            break;
    }
    
    
    return failureReason;
}

- (NSString *)localizedRecoverySuggestion {
    
    NSString *fixSuggestion = nil;
    
    switch (self.code) {
            
        case kPNClientConfigurationError:
            
            fixSuggestion = @"Ensure that you specified all required keys while creating PNConfiguration instance or all values specified in PNDefaultConfiguration.h. You can always visit https://admin.pubnub.comto get all required keys for PubNub client";
            break;
        case kPNClientConnectWhileConnected:
            
            fixSuggestion = @"If it is required to reconnect PubNub client, close connection first and then try connect again";
            break;
        case kPNClientConnectionFailedOnInternetFailure:
            
            fixSuggestion = @"Ensure that all network configuration (including proxy if there is) is correct and try again";
            break;
            
        default:
            break;
    }
    
    
    return fixSuggestion;
}

- (NSString *)domainForError:(NSInteger)errorCode {
    
    NSString *domain = kPNDefaultErrorDomain;
    
    
    return domain;
}

#pragma mark -


@end
