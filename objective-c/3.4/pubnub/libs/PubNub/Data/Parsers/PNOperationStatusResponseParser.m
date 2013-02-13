//
//  PNOperationStatusResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNOperationStatusResponseParser.h"
#import "PNOperationStatus+Protected.h"
#import "PNResponse.h"


#pragma mark Static

// Stores reference on index under which request
// execution status code is stored
static NSUInteger const kPNResponseStatusCodeElementIndex = 0;

// Stores reference on index under which request
// execution status description is stored
static NSUInteger const kPNResponseStatusCodeDescriptionElementIndex = 1;

// Stores reference on time token element index in
// response for request status
static NSUInteger const kPNResponseStatusTimeTokenElementIndexForStatus = 2;


#pragma mark - Private interface methods

@interface PNOperationStatusResponseParser ()


#pragma mark - Properties

// Stores reference on status description instance
@property (nonatomic, strong) PNOperationStatus *operationStatus;


@end


#pragma mark - Public interface methods

@implementation PNOperationStatusResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSArray *responseData = response.response;

        self.operationStatus = [PNOperationStatus new];
        self.operationStatus.successful = [[responseData objectAtIndex:kPNResponseStatusCodeElementIndex] intValue] != 0;
        self.operationStatus.statusDescription = [responseData objectAtIndex:kPNResponseStatusCodeDescriptionElementIndex];

        if (!self.operationStatus.isSuccessful) {

            self.operationStatus.error = [PNError errorWithResponseErrorMessage:self.operationStatus.statusDescription];
        }

        if ([responseData count] > kPNResponseStatusTimeTokenElementIndexForStatus) {

            id timeToken = [responseData objectAtIndex:kPNResponseStatusTimeTokenElementIndexForStatus];
            self.operationStatus.timeToken = PNNumberFromUnsignedLongLongString(timeToken);
        }
    }


    return self;
}

- (id)parsedData {

    return self.operationStatus;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <successful: %@, message: %@, time token: %@, error: %@>",
                    NSStringFromClass([self class]),
                    self,
                    self.operationStatus.isSuccessful?@"YES":@"NO",
                    self.operationStatus.statusDescription,
                    self.operationStatus.timeToken,
                    self.operationStatus.error];
}

#pragma mark -


@end