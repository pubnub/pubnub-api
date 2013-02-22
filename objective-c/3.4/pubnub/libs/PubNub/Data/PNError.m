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

#import "PNError+Protected.h"


#pragma mark - Private interface methods

@interface PNError ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *errorMessage;

// Stores reference on associated object with which
// error is occurred
@property (nonatomic, strong) id associatedObject;


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

    return [self errorWithMessage:nil code:errorCode];
}

+ (PNError *)errorWithResponseErrorMessage:(NSString *)errorMessage {

    NSInteger errorCode = kPNUnknownError;

    // Check whether error message tell something about presence
    // (this mean that PubNub client tried to use presence API
    // which is not enabled on https://admin.pubnub.com
    if ([errorMessage rangeOfString:@"Presence"].location != NSNotFound) {

        errorCode = kPNPresenceAPINotAvailableError;
    }
    // Check whether error caused by malformed data sent to the PubNub service
    else if ([errorMessage rangeOfString:@"Invalid"].location != NSNotFound) {

        // Check whether server reported that wrong JSON format has been sent
        // to it
        if ([errorMessage rangeOfString:@"JSON"].location != NSNotFound) {

            errorCode = kPNInvalidJSONError;
        }
        // Check whether restricted characters has been used in request
        else if ([errorMessage rangeOfString:@"Character"].location != NSNotFound) {

            // Check whether restricted characters has been used in channel names
            if ([errorMessage rangeOfString:@"Channel"].location != NSNotFound) {

                errorCode = kPNRestrictedCharacterInChannelNameError;
            }
        }
        // Check whether wrong key was specified for request
        else if([errorMessage rangeOfString:@"Key"].location != NSNotFound) {

            errorCode = kPNInvalidSubscribeOrPublishKeyError;
        }
    }
    // Check whether error caused by message content or not
    else if ([errorMessage rangeOfString:@"Message"].location != NSNotFound) {

        // Check whether message is too long or not
        if ([errorMessage rangeOfString:@"Too Large"].location != NSNotFound) {

            errorCode = kPNTooLongMessageError;
        }
    }
    else {

    }

    PNError *error = nil;
    if (errorCode == kPNUnknownError) {

        error = [PNError errorWithMessage:errorMessage code:errorCode];
    }
    else {

        error = [self errorWithCode:errorCode];
    }


    return error;
}

+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode {
    
    return [[[self class] alloc] initWithMessage:errorMessage code:errorCode];
}


#pragma mark - Instance methods

- (id)initWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode {

    // Check whether initialization successful or not
    if((self = [super initWithDomain:[self domainForError:errorCode] code:errorCode userInfo:nil])) {

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
            case kPNClientTriedConnectWhileConnectedError:
                
                errorDescription = @"PubNub client already connected to origin";
                break;
            case kPNClientConnectionFailedOnInternetFailureError:
                
                errorDescription = @"PubNub client connection failed";
                break;
            case kPNClientConnectionClosedOnInternetFailureError:

                errorDescription = @"PubNub client connection lost connection";
                break;
            case kPNRequestExecutionFailedOnInternetFailureError:
            case kPNRequestExecutionFailedClientNotReadyError:
                
                errorDescription = @"PubNub client can't perform request";
                break;
            case kPNConnectionErrorOnSetup:
                
                errorDescription = @"PubNub client connection can't be opened";
                break;
            case kPNPresenceAPINotAvailableError:

                errorDescription = @"PubNub client can't use presence API";
                break;
            case kPNInvalidJSONError:

                errorDescription = @"PubNub service can't process JSON";
                break;
            case kPNInvalidSubscribeOrPublishKeyError:

                errorDescription = @"PubNub service can't process request";
                break;
            case kPNRestrictedCharacterInChannelNameError:

                errorDescription = @"PubNub service process request for channel";
                break;
            case kPNMessageHasNoContentError:
            case kPNMessageHasNoChannelError:
            case kPNTooLongMessageError:
            case kPNMessageObjectError:

                errorDescription = @"PubNub client can't submit message";
                break;
            default:

                errorDescription = @"Unknown error.";
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
        case kPNClientTriedConnectWhileConnectedError:
            
            failureReason = @"Looks like client tried to connecte to remote PubNub service while already has connection";
            break;
        case kPNClientConnectionFailedOnInternetFailureError:
            
            failureReason = @"Looks like client lost connection while trying to connect to remote PubNub service";
            break;
        case kPNRequestExecutionFailedOnInternetFailureError:
        case kPNClientConnectionClosedOnInternetFailureError:
            
            failureReason = @"Looks like client lost connection";
            break;
        case kPNRequestExecutionFailedByTimeoutError:

            failureReason = @"Looks like there is some packets lost because of which request failed by timeout";
            break;
        case kPNConnectionErrorOnSetup:
            
            failureReason = @"Connection can't be opened becuase of errors in configuration";
            break;
        case kPNRequestExecutionFailedClientNotReadyError:

            failureReason = @"Looks like client is not connected to PubNub service";
            break;
        case kPNPresenceAPINotAvailableError:

            failureReason = @"Looks like presence API access not enabled";
            break;
        case kPNInvalidJSONError:

            failureReason = @"Looks like one of requests tried to send malformed JSON or message hase been changed after signature was generated";
            break;
        case kPNInvalidSubscribeOrPublishKeyError:

            failureReason = @"Looks like one of subscribe or publish key is wrong";
            break;
        case kPNRestrictedCharacterInChannelNameError:

            failureReason = @"Looks like one of reqests used restricted characters in channel name";
            break;
        case kPNMessageHasNoContentError:

            failureReason = @"Looks like message has empty body or doesnt have it at all";
            break;
        case kPNMessageHasNoChannelError:

            failureReason = @"Looks like target channel for message not specified";
            break;
        case kPNMessageObjectError:

            failureReason = @"Looks like there is no message object has been passed";
            break;
        case kPNTooLongMessageError:

            failureReason = @"Looks like message is too large and can't be processed";
            break;
        default:

            failureReason = @"Unknown error reason.";
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
        case kPNClientTriedConnectWhileConnectedError:
            
            fixSuggestion = @"If it is required to reconnect PubNub client, close connection first and then try connect again";
            break;
        case kPNClientConnectionFailedOnInternetFailureError:
        case kPNRequestExecutionFailedOnInternetFailureError:
            
            fixSuggestion = @"Ensure that all network configuration (including proxy if there is) is correct and try again";
            break;
        case kPNConnectionErrorOnSetup:
            
            fixSuggestion = @"Check whether client was configured to use secure connection and whether remote origin has valid certificate.\nIf remote origin doesn't provide correct SSL certificate, you can set kPNShouldReduceSecurityLevelOnError to YES in PNDefaultConfiguration.h or provide YES when initializing PNConfiguration instance.";
            break;
        case kPNRequestExecutionFailedClientNotReadyError:

            fixSuggestion = @"Ensure that PubNub client connected to the PubNub service and try again.";
            break;
        case kPNRequestExecutionFailedByTimeoutError:

            fixSuggestion = @"Try send request again later.";
            break;
        case kPNPresenceAPINotAvailableError:

            fixSuggestion = @"Please visit https://admin.pubnub.com and enable presence API feature and try again.";
            break;
        case kPNInvalidJSONError:

            fixSuggestion = @"Review all JSON request which is sent for processing to the PubNub services. Ensure that you don't try to change message while request is prepared.";
            break;
        case kPNInvalidSubscribeOrPublishKeyError:

            fixSuggestion = @"Review request and ensure that correct publish or(and) subscribe key was specified in it";
            break;
        case kPNRestrictedCharacterInChannelNameError:

            fixSuggestion = @"Ensure that you don't use in channel name next characters: ','";
            break;
        case kPNMessageHasNoContentError:

            fixSuggestion = @"Ensure that you are not sending empty message (maybe there only spaces in it).";
            break;
        case kPNMessageHasNoChannelError:

            fixSuggestion = @"Ensure that you specified valid channel as message target";
            break;
        case kPNTooLongMessageError:

            fixSuggestion = @"Please visit https://admin.pubnub.com and change maximum message size.";
            break;
        case kPNMessageObjectError:

            fixSuggestion = @"Ensure that you provide correct message object to be used for sending request";
            break;
        default:

            fixSuggestion = @"There is no known solutions.";
            break;
    }
    
    
    return fixSuggestion;
}

- (NSString *)domainForError:(NSInteger)errorCode {
    
    NSString *domain = kPNDefaultErrorDomain;

    switch (errorCode) {

        case kPNPresenceAPINotAvailableError:
        case kPNInvalidJSONError:
        case kPNRestrictedCharacterInChannelNameError:

                domain = kPNServiceErrorDomain;
            break;
        default:
            break;
    }
    
    return domain;
}

#pragma mark -


@end
