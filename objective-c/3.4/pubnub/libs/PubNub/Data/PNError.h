//
//  PNError.h
//  pubnub
//
//  Class which will be used to describe internal
//  PubNub client errors.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import <Foundation/Foundation.h>
#import "PNErrorCodes.h"


#pragma mark Static

// Stores reference on error domain which is used to specify
// that this error arrived because of client inconsistency
// or some validation on the client
static NSString * const kPNDefaultErrorDomain = @"com.pubnub.pubnub";

// Stores reference on error domain which is used to specify
// that this error arrived because of remote service error
static NSString * const kPNServiceErrorDomain = @"com.pubnub.remote-service";


@interface PNError : NSError


#pragma mark - Properties

// Stores reference on associated object with which
// error is occurred
@property (nonatomic, readonly, strong) id associatedObject;


#pragma mark - Class methods

+ (PNError *)errorWithResponseErrorMessage:(NSString *)errorMessage;
+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode;
+ (PNError *)errorWithCode:(NSInteger)errorCode;


#pragma mark - Instance methods

- (id)initWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode;

#pragma mark -


@end
