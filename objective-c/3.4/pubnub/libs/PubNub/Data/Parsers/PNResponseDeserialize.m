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
#import "NSData+PNAdditions.h"
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
// to find HTTP header which is responsible for
// whether response in sent in chunked form or not
@property (nonatomic, strong) NSData *httpChunkedTransferEncodingData;

// Stores reference on data object which is used
// to mark chunked content end in HTTP response
// body
@property (nonatomic, strong) NSData *httpChunkedContentEndData;

// Store reference on data object which is used
// to find HTTP header which tells us if the response
// is GZIPped
@property (nonatomic, strong) NSData *httpContentEncodingGZIP;

// Stores reference on data object which is used
// to find HTTP headers and content separator
@property (nonatomic, strong) NSData *httpContentSeparatorData;

// Stores reference on data object which is used
// to find new line char in provided data
@property (nonatomic, strong) NSData *endLineCharacterData;

// Stores reference on data object which is used
// to find new line chars (\r\n) in provided data
@property (nonatomic, strong) NSData *endLineCharactersData;


// Stores reference on data object which is used
// to spacebars in specified piece of data
@property (nonatomic, strong) NSData *spaceCharacterData;

// Reflects whether deserializer still working or not
@property (nonatomic, assign, getter = isDeserializing) BOOL deserializing;


#pragma mark - Instance methods

- (PNResponse *)responseInRange:(NSRange)responseRange ofData:(NSData *)data;

- (NSInteger)responseStatusCodeFromData:(NSData *)data inRange:(NSRange)responseRange;
- (BOOL)isChunkedResponse:(NSData *)data inRange:(NSRange)responseRange;
- (NSInteger)responseSizeFromData:(NSData *)data
               forChunkedResponse:(BOOL)isChunked
                          inRange:(NSRange)responseRange
          chunkedContentSizeRange:(NSRange*)chunkedContentSizeRange;

/**
 * Return reference on index where next HTTP
 * response starts (searching index of "HTTP/1.1"
 * string after current one)
 */
- (NSUInteger)nextResponseStartIndexForData:(NSData *)data inRange:(NSRange)responseRange;

- (NSRange)nextResponseStartSearchRangeInRange:(NSRange)responseRange;
- (NSRange)contentSeparatorRangeForData:(NSData *)data inRange:(NSRange)responseRange;

/**
 * Return whether HTTP response contains information
 * on whether it is compressed or not
 */
- (BOOL)isCompressedResponse:(NSData *)data inRange:(NSRange)responseRange;

/**
 * Allow to find piece of data enclosed between two 
 * othere pieces of data which is used as markers
 */
- (NSData *)dataBetween:(NSData *)startData
                 andEnd:(NSData *)endData
                 inData:(NSData *)data
              withRange:(NSRange)searchRange
              dataRange:(NSRange*)searchedDataRange;

/**
 * Allow to compose response data object from chunked
 * data by separating it on chink size markers and joining
 * rest of data
 */
- (NSData *)joinedDataFromChunkedData:(NSData *)chunkedData;

/**
 * Allow to compose response data object from chunked data using
 * octet values to determine next chunk size
 */
- (NSData *)joinedDataFromChunkedDataUsingOctets:(NSData *)chunkedData inRange:(NSRange)searchRange;


@end


#pragma mark Public interface methods

@implementation PNResponseDeserialize


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.httpHeaderStartData = [@"HTTP/1.1 " dataUsingEncoding:NSUTF8StringEncoding];
        self.httpContentLengthData = [@"Content-Length: " dataUsingEncoding:NSUTF8StringEncoding];
        self.httpChunkedTransferEncodingData = [@"Transfer-Encoding: chunked" dataUsingEncoding:NSUTF8StringEncoding];
        self.httpContentEncodingGZIP = [@"Content-Encoding: gzip" dataUsingEncoding:NSUTF8StringEncoding];
        self.httpChunkedContentEndData = [@"0\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.httpContentSeparatorData = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.endLineCharacterData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.endLineCharactersData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.spaceCharacterData = [@" " dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    return self;
}

- (NSArray *)parseResponseData:(NSMutableData *)data {
    
    self.deserializing = YES;
    
    NSMutableArray *parsedData = [NSMutableArray array];
    NSRange responseRange = NSMakeRange(0, [data length]);
    NSRange contentRange = NSMakeRange(0, [data length]);
    
    
    @autoreleasepool {
        
        NSUInteger nextResponseIndex = [self nextResponseStartIndexForData:data inRange:responseRange];
        if (nextResponseIndex == NSNotFound) {
            
            // Try construct response instance
            PNResponse *response = [self responseInRange:contentRange ofData:data];
            if(response) {

                [parsedData addObject:response];
            }
            else {
                
                contentRange = NSMakeRange(NSNotFound, 0);
            }
        }
        else {
            
            // Stores previous content range and will be used to
            // update current content range in case of parsing error
            // (maybe tried parse incomplete response)
            NSRange previousContentRange = NSMakeRange(NSNotFound, 0);
            
            // Search for another responses while it is possible
            while (nextResponseIndex != NSNotFound) {
                
                contentRange.length = nextResponseIndex - contentRange.location;
                
                
                // Try construct response instance
                PNResponse *response = [self responseInRange:contentRange ofData:data];
                if(response) {

                    [parsedData addObject:response];

                    
                    // Update content search range
                    responseRange.location = responseRange.location + contentRange.length;
                    responseRange.length = responseRange.length - contentRange.length;
                    if(responseRange.length > 0) {
                        
                        nextResponseIndex = [self nextResponseStartIndexForData:data inRange:responseRange];
                        if(nextResponseIndex == NSNotFound) {
                            
                            nextResponseIndex = responseRange.location + responseRange.length;
                        }
                        
                        previousContentRange.location = contentRange.location;
                        previousContentRange.length = contentRange.length;
                        contentRange.location = responseRange.location;
                    }
                    else {
                        
                        nextResponseIndex = NSNotFound;
                    }
                }
                else {

                    nextResponseIndex = NSNotFound;
                    contentRange.location = previousContentRange.location;
                    contentRange.length = previousContentRange.length;
                }
            }
        }
    }
    
    
    if(contentRange.location != NSNotFound) {
        
        // Update provided data to remove from it
        // response content which successfully was
        // parsed
        NSUInteger lastResponseEndIndex = contentRange.location + contentRange.length;
        [data setData:[data subdataWithRange:NSMakeRange(lastResponseEndIndex, [data length]-lastResponseEndIndex)]];
    }
    
    self.deserializing = NO;
    
    
    return parsedData;
}

- (PNResponse *)responseInRange:(NSRange)responseRange ofData:(NSData *)data {
    
    PNResponse *response = nil;
    NSUInteger responseEndIndex = (responseRange.location + responseRange.length);
    
    // Try to fetch HTTP status from body
    NSUInteger statusCode = [self responseStatusCodeFromData:data inRange:responseRange];

    NSRange chunkedContentSizeRange = NSMakeRange(NSNotFound, 0);
    BOOL responseIsChunked = [self isChunkedResponse:data inRange:responseRange];
    NSUInteger contentSize = [self responseSizeFromData:data
                                     forChunkedResponse:responseIsChunked
                                                inRange:responseRange
                                chunkedContentSizeRange:&chunkedContentSizeRange];
    if(contentSize > 0) {

        // Searching for HTTP header and response content
        // separator
        NSRange separatorRange = [self contentSeparatorRangeForData:data inRange:responseRange];
        if(separatorRange.location != NSNotFound) {

            // Check whether full response body loaded or not
            // (taking into account content size which arrived
            // in HTTP header)
            BOOL isFullBody = NO;
            NSUInteger contentSeparatorEndIndex = (separatorRange.location+separatorRange.length);

            if(!responseIsChunked) {

                NSUInteger contentSizeLeft = (responseRange.location + responseRange.length) - contentSeparatorEndIndex;
                isFullBody = contentSizeLeft > 0 && contentSize == contentSizeLeft;
            }
            else {

                // Retrieve range of content end
                NSRange contentEndRange = [data rangeOfData:self.httpChunkedContentEndData
                                                    options:NSDataSearchBackwards
                                                      range:responseRange];

                if (contentEndRange.location != NSNotFound) {

                    NSUInteger contentEndRangeIndex = contentEndRange.location + contentEndRange.length;
                    isFullBody = responseEndIndex == contentEndRangeIndex;

                    contentSeparatorEndIndex = chunkedContentSizeRange.location + chunkedContentSizeRange.length;
                    contentSeparatorEndIndex += [self.endLineCharactersData length];
                    contentSize = contentEndRangeIndex-contentSeparatorEndIndex;
                }
            }

            if (isFullBody) {

                NSRange responseContentRange = NSMakeRange(contentSeparatorEndIndex, contentSize);
                NSData *responseData = [data subdataWithRange:responseContentRange];
                if (responseIsChunked) {

                    if ([self isCompressedResponse:data inRange:responseRange]) {

                        responseData = [[self joinedDataFromChunkedDataUsingOctets:data inRange:responseRange] GZIPInflate];
                    }
                    else {
                        responseData = [self joinedDataFromChunkedData:responseData];
                    }
                }
                PNLog(PNLogGeneralLevel, self, @"RAW DATA: %@", [[NSString alloc] initWithData:responseData
                                                                                      encoding:NSUTF8StringEncoding]);
                response = [PNResponse responseWithContent:responseData size:responseRange.length code:statusCode];
            }
        }
    }
    
    
    return response;
}

- (NSInteger)responseStatusCodeFromData:(NSData *)data inRange:(NSRange)responseRange {
    
    NSInteger statusCode = 0;
    NSData *responseStatusCodeData = [self dataBetween:self.httpHeaderStartData
                                                andEnd:self.spaceCharacterData
                                                inData:data
                                             withRange:responseRange
                                             dataRange:NULL];
    
    if (responseStatusCodeData != nil) {

        statusCode = strtol([responseStatusCodeData bytes], NULL, 0);
    }
    
    
    return statusCode;
}

- (BOOL)isChunkedResponse:(NSData *)data inRange:(NSRange)responseRange {

    NSRange chunkedMarkerRange = [data rangeOfData:self.httpChunkedTransferEncodingData
                                           options:(NSDataSearchOptions)0
                                             range:responseRange];

    return chunkedMarkerRange.location != NSNotFound;
}

- (NSInteger)responseSizeFromData:(NSData *)data
               forChunkedResponse:(BOOL)isChunked
                          inRange:(NSRange)responseRange
          chunkedContentSizeRange:(NSRange*)chunkedContentSizeRange {
    
    NSInteger contentSize = 0;

    if (!isChunked) {

        NSData *contentSizeData = [self dataBetween:self.httpContentLengthData
                                             andEnd:self.endLineCharacterData
                                             inData:data
                                          withRange:responseRange
                                          dataRange:NULL];
        if (contentSizeData != nil) {

            contentSize = strtoull([contentSizeData bytes], NULL, 0);
        }
    }
    else {

        // Check whether chunked content size marker is found or not
        NSData *chunkedContentSizeMarker = [self dataBetween:self.httpContentSeparatorData
                                                      andEnd:self.endLineCharactersData
                                                      inData:data
                                                   withRange:responseRange
                                                   dataRange:chunkedContentSizeRange];

        if (chunkedContentSizeMarker) {

            contentSize = [chunkedContentSizeMarker unsignedLongLongFromHEXData];
        }
    }
    
    
    return contentSize;
}

- (BOOL)isCompressedResponse:(NSData *)data inRange:(NSRange)responseRange {

    NSRange contentEncodingGzipRange = [data rangeOfData:self.httpContentEncodingGZIP
                                                 options:(NSDataSearchOptions)0
                                                   range:responseRange];


    return contentEncodingGzipRange.location != NSNotFound;
}



- (NSData *)dataBetween:(NSData *)startData
                 andEnd:(NSData *)endData
                 inData:(NSData *)data
              withRange:(NSRange)searchRange
              dataRange:(NSRange*)searchedDataRange {
    
    NSData *result = nil;
    
    // Searching for content start marker
    NSRange startDataRange = [data rangeOfData:startData options:(NSDataSearchOptions)0 range:searchRange];
    if(startDataRange.location != NSNotFound) {

        NSUInteger startMarkerEndIndex = startDataRange.location+startDataRange.length;
        
        // Searching for content end marker
        NSRange endSearchRange = NSMakeRange(startMarkerEndIndex,
                                             (searchRange.location + searchRange.length) - startMarkerEndIndex);
        NSRange endDataRange = [data rangeOfData:endData options:(NSDataSearchOptions)0 range:endSearchRange];
        if (endDataRange.location != NSNotFound) {
            
            // Fetching data which is enclosed between two data markers
            NSRange resultRange = NSMakeRange(endSearchRange.location, (endDataRange.location-endSearchRange.location));
            result = [data subdataWithRange:resultRange];

            if (searchedDataRange != NULL) {

                *searchedDataRange = resultRange;
            }
        }
    }
    
    
    return result;
}

- (NSData *)joinedDataFromChunkedData:(NSData *)chunkedData {

    BOOL shouldAppendData = YES;
    NSMutableData *joinedData = [NSMutableData dataWithCapacity:[chunkedData length]];
    NSRange rangeToSearchIn = NSMakeRange(0, [chunkedData length]);
    NSRange chunkEndRange = [chunkedData rangeOfData:self.endLineCharactersData
                                             options:(NSDataSearchOptions)0
                                               range:rangeToSearchIn];
    while (chunkEndRange.location != NSNotFound) {

        NSUInteger chunkedDataLength = chunkEndRange.location - rangeToSearchIn.location;

        if (shouldAppendData) {

            [joinedData appendData:[chunkedData subdataWithRange:NSMakeRange(rangeToSearchIn.location, chunkedDataLength)]];
        }

        rangeToSearchIn.length -= (chunkedDataLength + chunkEndRange.length);
        rangeToSearchIn.location = chunkEndRange.location + chunkEndRange.length;

        chunkEndRange = [chunkedData rangeOfData:self.endLineCharactersData
                                         options:(NSDataSearchOptions)0
                                           range:rangeToSearchIn];

        shouldAppendData = !shouldAppendData;
    }


    return joinedData;
}

- (NSData *)joinedDataFromChunkedDataUsingOctets:(NSData *)chunkedData inRange:(NSRange)searchRange {

    NSMutableData *joinedData = [NSMutableData data];
    BOOL parsingChunkOctet = NO;
    BOOL parsingChunk = NO;
    int chunkStart = 0;

    NSRange cursor = [chunkedData rangeOfData:self.endLineCharactersData
                                      options:(NSDataSearchOptions)0
                                        range:searchRange];

    while (cursor.location != NSNotFound) {

        // When the loop starts chunkStart points to the first byte of the chunk
        // we are processing, and cursor points to byte that signifies the end
        // of the chunk (which is always \r\n).
        // The chunk NSData can be a header, a chunk octet, or an actual chunk.
        NSData *chunk = [chunkedData subdataWithRange:NSMakeRange(chunkStart, cursor.location - chunkStart)];

        // The next chunk starts after the cursor.
        chunkStart = cursor.location + cursor.length;
        NSRange nextSearchRange = NSMakeRange(chunkStart, searchRange.length - chunkStart);

        if (parsingChunk) {

            parsingChunk = NO;
            parsingChunkOctet = YES;

            [joinedData appendData:chunk];

            cursor = [chunkedData rangeOfData:self.endLineCharactersData
                                      options:(NSDataSearchOptions)0
                                        range:nextSearchRange];
        }
        else if (parsingChunkOctet) {

            parsingChunkOctet = NO;
            parsingChunk = YES;

            NSString *octet = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
            NSScanner *scanner = [NSScanner scannerWithString:octet];
            unsigned int chunkSize = 0;
            [scanner scanHexInt:&chunkSize];

            // Check whether octet report that next chunk of data will
            // be zero length or not
            if (chunkSize == 0) {

                break;
            }

            cursor = NSMakeRange(chunkStart + chunkSize, [self.endLineCharactersData length]);
        }
        else {

            if ([chunk length] <= 0) {

                parsingChunkOctet = YES;
            }

            cursor = [chunkedData rangeOfData:self.endLineCharactersData
                                      options:(NSDataSearchOptions)0
                                        range:nextSearchRange];
        }
    }


    return joinedData;
}

- (NSUInteger)nextResponseStartIndexForData:(NSData *)data inRange:(NSRange)responseRange {
    
    NSRange range = [data rangeOfData:self.httpHeaderStartData
                              options:(NSDataSearchOptions)0
                                range:[self nextResponseStartSearchRangeInRange:responseRange]];
    
    
    return range.location;
}

- (NSRange)nextResponseStartSearchRangeInRange:(NSRange)responseRange; {
    
    return NSMakeRange(responseRange.location + 1, responseRange.length-1);
}

- (NSRange)contentSeparatorRangeForData:(NSData *)data inRange:(NSRange)responseRange {

    return [data rangeOfData:self.httpContentSeparatorData options:(NSDataSearchOptions)0 range:responseRange];
}

#pragma mark -


@end
