//
//  PNHereNowResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNHereNowResponseParser.h"
#import "PNHereNowResponseParser+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNResponse.h"


#pragma mark Private interface methods

@interface PNHereNowResponseParser ()


#pragma mark - Properties

// Stores reference on object which stores information
// about who is in the channel and how many of them
@property (nonatomic, strong) PNHereNow *hereNow;


@end


#pragma mark - Public interface methods

@implementation PNHereNowResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSDictionary *responseData = response.response;

        self.hereNow = [PNHereNow new];
        self.hereNow.participants = [responseData objectForKey:kPNResponseUUIDKey];
        self.hereNow.participantsCount = [[responseData objectForKey:kPNResponseOccupancyKey] unsignedIntValue];
    }


    return self;
}

- (id)parsedData {

    return self.hereNow;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <participants: %@, participants count: %i, channel: %@>",
                    NSStringFromClass([self class]),
                    self,
                    self.hereNow.participants,
                    self.hereNow.participantsCount,
                    self.hereNow.channel];
}

#pragma mark -


@end