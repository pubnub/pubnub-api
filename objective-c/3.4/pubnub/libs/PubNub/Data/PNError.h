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


#pragma mark Static

// Stores reference on error domain which is used to specify
// that this error arrived because of client inconsistence
// or some validation on the client
static NSString * const kPNDefaultErrorDomain = @"com.pubnub.pubnub";

// Stores reference on error domain which is used to specify
// that this error arrived because of remote service error
static NSString * const kPNServiceErrorDomain = @"com.pubnub.remote-service";


@interface PNError : NSError


#pragma mark - Class methods

+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode;
+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode channel:(NSString *)channelName;
+ (PNError *)errorWithCode:(NSInteger)errorCode;
+ (PNError *)errorWithCode:(NSInteger)errorCode channel:(NSString *)channelName;


#pragma mark - Instance methods

- (id)initWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode channel:(NSString *)channelName;

#pragma mark -


@end
