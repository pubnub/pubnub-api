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


#pragma mark Private interface methods

@interface PNResponse ()

#pragma mark Properties

@property (nonatomic, strong) NSData *content;
@property (nonatomic, assign) NSUInteger statusCode;
@property (nonatomic, assign) NSUInteger size;


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
 * Intialize response instance with response
 * body content data, response size and status
 * code (HTTP status code)
 */
- (id)initWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSUInteger)statusCode {
    
    // Check whether intialization was successful or not
    if((self = [super init])) {
     
        self.content = content;
        self.size = responseSize;
        self.statusCode = statusCode;
    }
    
    
    return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"\nHTTP STATUS CODE: %i\nRESPONSE SIZE: %i\nRESPONSE CONTENT SIZE: %i\nRESPONSE: %@\n",
            self.statusCode,
            [self.content length],
            self.size,
            [[NSString alloc] initWithUTF8String:[self.content bytes]]];
}

#pragma mark -


@end
