//
//  PNActionResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNActionResponseParser.h"
#import "PNActionResponseParser+Protected.h"
#import "PNStructures.h"
#import "PNResponse.h"


#pragma mark Private interface methods

@interface PNActionResponseParser ()


#pragma mark - Properties

// Stores reference on action type
@property (nonatomic, assign) PNOperationResultEvent actionType;


@end


#pragma mark - Public interface methods

@implementation PNActionResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSString *action = [response.response objectForKey:kPNResponseActionKey];
        if ([action isEqualToString:@"leave"]) {

            self.actionType = PNOperationResultLeave;
        }
    }


    return self;
}

- (id)parsedData {

    return [NSNumber numberWithInt:self.actionType];
}

- (NSString *)description {

    NSString *action = @"unknown";
    switch (self.actionType) {

        case PNOperationResultLeave:

            action = @"leave";
            break;
        default:
            break;
    }


    return [NSString stringWithFormat:@"%@ (%p): <action: %@>", NSStringFromClass([self class]), self, action];
}


#pragma mark -


@end