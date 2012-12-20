//
//  PNResponseDeserialize.m
//  pubnub
//
//  This class was created to help deserialize
//  responses which connection recieves over the
//  stream opened on sockets.
//  Server returns formatted HTTP headers with response
//  body which should be extracted.
//
//
//  Created by Sergey Mamontov on 12/19/12.
//
//

#import "PNResponseDeserialize.h"
#import "PNResponse.h"


#pragma mark Private interface methods

@interface PNResponseDeserialize ()


#pragma mark - Properties

// Stores reference on data object which is used
// to find response block start
@property (nonatomic, strong) NSData *httpHeaderStartData;

// Stores reference on data object which is used
// to find HTTP header which is responsible for
// response content size
@property (nonatomic, strong) NSData *httpContentLengthData;

// Stores reference on data object which is used
// to find HTTP headers and content separator
@property (nonatomic, strong) NSData *httpContentSeparatorData;

// Stores reference on data object which is used
// to find new line char in provided data
@property (nonatomic, strong) NSData *endLineCharacterData;

// Stores reference on data object which is used
// to spacebars in specified piece of data
@property (nonatomic, strong) NSData *spaceCharacterData;


#pragma mark - Instance methods

- (PNResponse *)responseInRange:(NSRange)responseRange ofData:(NSData *)data;

- (NSInteger)responseStatusCodeFromData:(NSData *)data inRange:(NSRange)responseRange;
- (NSInteger)responseSizeFromData:(NSData *)data inRange:(NSRange)responseRange;

/**
 * Return reference on index where next HTTP
 * response starts (searching index of "HTTP/1.1"
 * string after current one)
 */
- (NSUInteger)nextResponseStartIndexForData:(NSData *)data inRange:(NSRange)responseRange;

- (NSRange)nextResponseStartSearchRangeForData:(NSData *)data;

/**
 * Allow to find piece of data enclosed between two 
 * othere pieces of data which is used as markers
 */
- (NSData *)dataBetween:(NSData *)startData
                 andEnd:(NSData *)endData
                 inData:(NSData *)data
              withRange:(NSRange)searchRange;

@end


#pragma mark Public interface methods

@implementation PNResponseDeserialize


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.httpHeaderStartData = [@"HTTP/1.1 " dataUsingEncoding:NSUTF8StringEncoding];
        self.httpContentLengthData = [@"Content-Length: " dataUsingEncoding:NSUTF8StringEncoding];
        self.httpContentSeparatorData = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.endLineCharacterData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.spaceCharacterData = [@" " dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    return self;
}

- (NSArray *)parseResponseData:(NSMutableData *)data {
    
    NSMutableArray *parsedData = [NSMutableArray array];
    NSRange responseRange = NSMakeRange(0, [data length]);
    
    
    @autoreleasepool {
        
        NSUInteger nextResponseIndex = [self nextResponseStartIndexForData:data inRange:responseRange];
        if (nextResponseIndex == NSNotFound) {
            
            // Try contruct response instance
            PNResponse *response = [self responseInRange:responseRange ofData:data];
            if(response) {
                
                [parsedData addObject:response];
            }
        }
        else {
            
            // Search for another responses while it is possible
            while (nextResponseIndex != NSNotFound) {
                
                responseRange.length = nextResponseIndex - responseRange.location;
                
                
                // Try contruct response instance
                PNResponse *response = [self responseInRange:responseRange ofData:data];
                if(response) {
                    
                    [parsedData addObject:response];
                }
                
                nextResponseIndex = [self nextResponseStartIndexForData:data inRange:responseRange];
            }
        }
    }
    
    
    // Update provided data to remove from it
    // response content which successfully was
    // parsed
    NSUInteger lastResponseEndIndex = responseRange.location + responseRange.length;
    [data setData:[data subdataWithRange:NSMakeRange(lastResponseEndIndex, [data length]-lastResponseEndIndex)]];
    
    
    return parsedData;
}

- (PNResponse *)responseInRange:(NSRange)responseRange ofData:(NSData *)data {
    
    PNResponse *response = nil;
    NSUInteger responseSize = [[data subdataWithRange:responseRange] length];
    
    // Try to fetch HTTP status from body
    NSUInteger statusCode = [self responseStatusCodeFromData:data inRange:responseRange];
    
    if (statusCode == 200) {
        
        NSUInteger contentSize = [self responseSizeFromData:data inRange:responseRange];
        if(contentSize > 0) {
            
            // Searching for HTTP header and response content
            // separator
            NSRange separatorRange = [data rangeOfData:self.httpContentSeparatorData options:0 range:responseRange];
            if(separatorRange.location != NSNotFound) {
                
                
                // Check whether full response body loaded or not
                // (taking into account content size which arrived
                // in HTTP header)
                NSUInteger contentSizeLeft = responseRange.length-(separatorRange.location+separatorRange.length);
                if (contentSize == contentSizeLeft) {
                    
                    NSRange responseContenrRange = NSMakeRange((separatorRange.location+separatorRange.length), contentSize);
                    NSData *responseData = [data subdataWithRange:responseContenrRange];
                    
                    response = [PNResponse responseWithContent:responseData size:responseSize code:statusCode];
                }
            }
        }
    }
    else {
        
        response = [PNResponse responseWithContent:nil size:responseSize code:statusCode];
    }
    
    
    NSLog(@"RESPONSE: %@", response);
    
    
    return response;
}

- (NSInteger)responseStatusCodeFromData:(NSData *)data inRange:(NSRange)responseRange {
    
    NSInteger statusCode = 0;
    NSData *responseStatusCodeData = [self dataBetween:self.httpHeaderStartData
                                                andEnd:self.spaceCharacterData
                                                inData:data
                                             withRange:responseRange];
    
    if (responseStatusCodeData != nil) {
        
        statusCode = [[NSString stringWithUTF8String:[responseStatusCodeData bytes]] integerValue];
    }
    
    
    return statusCode;
}

- (NSInteger)responseSizeFromData:(NSData *)data inRange:(NSRange)responseRange {
    
    NSInteger contentSize = 0;
    NSData *contentSizeData = [self dataBetween:self.httpContentLengthData
                                         andEnd:self.endLineCharacterData
                                         inData:data
                                      withRange:responseRange];
    if (contentSizeData != nil) {
        
        contentSize = [[NSString stringWithUTF8String:[contentSizeData bytes]] integerValue];
    }
    
    
    return contentSize;
}

- (BOOL)hasMoreValidResponseInData:(NSMutableData *)data {
    
}

- (NSData *)dataBetween:(NSData *)startData
                 andEnd:(NSData *)endData
                 inData:(NSData *)data
              withRange:(NSRange)searchRange {
    
    NSData *result = nil;
    
    // Searching for content start marker
    NSRange startDataRange = [data rangeOfData:startData options:0 range:searchRange];
    if(startDataRange.location != NSNotFound) {
        
        NSUInteger startMarkerEndIndex = startDataRange.location+startDataRange.length;
        
        // Searching for content end marker
        NSRange endSearchRange = NSMakeRange(startMarkerEndIndex, searchRange.length-startMarkerEndIndex);
        NSRange endDataRange = [data rangeOfData:endData options:0 range:endSearchRange];
        if (endDataRange.location != NSNotFound) {
            
            // Fetching data which is enclosed between two data markers
            result = [data subdataWithRange:NSMakeRange(endSearchRange.location,
                                                        (endDataRange.location-endSearchRange.location))];
        }
    }
    
    
    return result;
}

- (NSUInteger)nextResponseStartIndexForData:(NSData *)data inRange:(NSRange)responseRange {
    
    NSRange range = [data rangeOfData:self.httpHeaderStartData
                              options:0
                                range:[self nextResponseStartSearchRangeForData:data]];
    
    
    return range.location;
}

- (NSRange)nextResponseStartSearchRangeForData:(NSData *)data {
    
    return NSMakeRange(1, [data length]-1);
}

#pragma mark -


@end
