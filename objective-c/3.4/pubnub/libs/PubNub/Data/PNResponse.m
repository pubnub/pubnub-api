//
//  PNResponse.m
//  pubnub
//
//  This class instance designed to store
//  binary response from backend with some
//  additional information which will help
//  to understand some metrics.
//
//
//  Created by Sergey Mamontov on 12/20/12.
//
//

#import "PNResponse.h"
#import "PNRequestsImport.h"


#pragma mark Static

// Stores index of callback method name in array
// which was created by splitting callback method
// from JSONP by '_' sign
static NSUInteger const kPNResponseCallbackMethodNameIndex = 0;

// Stores index of request identifier in array
// which was created by splitting callback method
// from JSONP by '_' sign
static NSUInteger const kPNResponseRequestIdentifierIndex = 1;


#pragma mark - Private interface methods

@interface PNResponse ()


#pragma mark - Properties

// Stores binary response from PubNub services
@property (nonatomic, strong) NSData *content;

// Stores HTTP status code which was returned
// on sent request
@property (nonatomic, assign) NSUInteger statusCode;

// Stores response size (including HTTP header
// fields)
@property (nonatomic, assign) NSUInteger size;

// Stores reference on error object which will hold
// any information about parsing error
@property (nonatomic, strong) PNError *error;

// Stores reference on request small identifier
// hash which will be used to find request
// which sent this request
@property (nonatomic, copy) NSString *requestIdentifier;

// Stores reference on callback function name
// which will be returned in JSONP response
@property (nonatomic, copy) NSString *callbackMethod;

// Stores reference on response body object
// (array in most of cases)
@property (nonatomic, strong) id response;


#pragma mark - Instance methods

#pragma mark - Handler methods

/**
 * Handle JSON encoding error and try perform additional tasks
 * to silently fallback this error
 */
- (void)handleJSONDecodeErrorWithCode:(NSUInteger)errorCode;


#pragma mark - Misc methods

/**
 * If user is using cypher key to send request
 * than it will be used to decode server response
 */
- (NSString *)decodedResponse;

/**
 * In case of JSON parsing error, this method will
 * allow to pull out information about request and
 * callback function from partial response
 */
- (void)getCallbackFunction:(NSString **)callback
          requestIdentifier:(NSString **)identifier
                   fromData:(NSData *)responseData;


@end


#pragma mark - Public interface methods

@implementation PNResponse


#pragma mark Class methods

/**
 * Retrieve instance which will hold information about
 * HTTP response body and size of whole response
 * (including HTTP headers)
 */
+ (PNResponse *)responseWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode {
    
    return [[[self class] alloc] initWithContent:content size:responseSize code:statusCode];
}


#pragma mark - Instance methods

/**
 * Initialize response instance with response
 * body content data, response size and status
 * code (HTTP status code)
 */
- (id)initWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {

        self.content = content;
        self.size = responseSize;
        self.statusCode = statusCode;
        
        
        NSString *decodedResponse = [self decodedResponse];
        if (decodedResponse) {

            [PNJSONSerialization JSONObjectWithString:decodedResponse
                                      completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){

                                          if (isJSONP) {

                                              NSArray *callbackMethodElements = [callbackMethodName componentsSeparatedByString:@"_"];

                                              if ([callbackMethodElements count] > 1) {

                                                  self.callbackMethod = [callbackMethodElements objectAtIndex:kPNResponseCallbackMethodNameIndex];
                                                  self.requestIdentifier = [callbackMethodElements objectAtIndex:kPNResponseRequestIdentifierIndex];
                                              }
                                              else {

                                                  self.callbackMethod = callbackMethodName;
                                              }

                                              self.response = result;
                                          }
                                      }
                                           errorBlock:^(NSError *error) {

                                               PNLog(PNLogGeneralLevel, self, @"ERROR: %@", error);
                                               [self handleJSONDecodeErrorWithCode:kPNResponseMalformedJSONError];
                                           }];
        }
        // Looks like message can't be decoded event from RAW response
        // looks like malformed data arrived with characters which can't
        // be encoded
        else {

            PNLog(PNLogGeneralLevel, self, @"FAILED TO DECODE DATA");
            [self handleJSONDecodeErrorWithCode:kPNResponseEncodingError];
        }
    }
    
    
    return self;
}

- (BOOL)isCorrectResponse {

    return (self.size > 0 && self.statusCode == 200);
}

#pragma mark - Handler methods

- (void)handleJSONDecodeErrorWithCode:(NSUInteger)errorCode {

    // Mark that request is failed to be processed correctly
    self.statusCode = errorCode;
    self.size = 0;

    self.error = [PNError errorWithCode:errorCode];

    NSString *callbackMethod;
    NSString *requestIdentifier;
    [self getCallbackFunction:&callbackMethod requestIdentifier:&requestIdentifier fromData:self.content];
    self.callbackMethod = callbackMethod;
    self.requestIdentifier = requestIdentifier;
}


#pragma mark - Misc methods

- (NSString *)decodedResponse {

    NSString *encodedString = [[NSString alloc] initWithData:self.content encoding:NSUTF8StringEncoding];
    encodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [encodedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)getCallbackFunction:(NSString **)callback
          requestIdentifier:(NSString **)identifier
                   fromData:(NSData *)responseData {


    // Trying to extract callback method and request identifier
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if (responseString) {

        NSRange openingBracketRange = [responseString rangeOfString:@"("];
        if (openingBracketRange.location != NSNotFound) {

            NSString *callbackMethod = [responseString substringToIndex:openingBracketRange.location];
            NSArray *callbackMethodElements = [callbackMethod componentsSeparatedByString:@"_"];

            if ([callbackMethodElements count] > 1) {

                if (callback != NULL) {

                    *callback = [callbackMethodElements objectAtIndex:kPNResponseCallbackMethodNameIndex];
                }

                if (identifier != NULL) {

                    *identifier = [callbackMethodElements objectAtIndex:kPNResponseRequestIdentifierIndex];
                }
            }
            else {

                if (callback != NULL) {

                    *callback = callbackMethod;
                }
            }
        }
    }
    else {

        if (callback != NULL) {

            // Assign 'subscription' callback method
            *callback = PNServiceResponseCallbacks.subscriptionCallback;
        }
    }
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"\nHTTP STATUS CODE: %i\nRESPONSE SIZE: %i\nRESPONSE CONTENT SIZE: %i\nIS JSONP: %@\nCALLBACK METHOD: %@\nREQUEST IDENTIFIER: %@\nRESPONSE: %@\n",
            self.statusCode,
            [self.content length],
            self.size,
            self.callbackMethod?@"YES":@"NO",
            self.callbackMethod,
            self.requestIdentifier,
            self.response];
}

#pragma mark -


@end
