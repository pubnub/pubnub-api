//
//  PNTimeTokenResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNTimeTokenResponseParser.h"
#import "PNResponse.h"


#pragma mark Private interface methods

@interface PNTimeTokenResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) NSNumber *timeToken;


#pragma mark - Instance methods

/**
 * Returns reference on initialized parser for concrete
 * response
 */
- (id)initWithResponse:(PNResponse *)response;


@end


#pragma mark Public interface methods

@implementation PNTimeTokenResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        id timeToken = [(NSArray *)response.response lastObject];
        self.timeToken = PNNumberFromUnsignedLongLongString(timeToken);
    }


    return self;
}

- (id)parsedData {

    return self.timeToken;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <time token: %@>",
                    NSStringFromClass([self class]),
                    self,
                    self.timeToken];
}

#pragma mark -


@end