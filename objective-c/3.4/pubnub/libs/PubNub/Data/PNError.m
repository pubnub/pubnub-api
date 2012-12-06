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
    
    // Check whether error message was specified or not
    if (self.errorMessage == nil) {
        
        switch (self.code) {
                
            default:
                break;
        }
    }
    
    
    return self.errorMessage;
}

- (NSString *)domainForError:(NSInteger)errorCode {
    
    NSString *domain = kPNDefaultErrorDomain;
    
    
    return domain;
}

#pragma mark -


@end
