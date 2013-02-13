//
//  PNMessageHistoryRequest.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNMessageHistoryRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNChannel+Protected.h"
#import "PNRequestsImport.h"
#import "PubNub+Protected.h"


#pragma mark Private interface methods

@interface PNMessageHistoryRequest ()


#pragma mark - Properties

// Stores reference on channel for which history should
// be pulled out
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on history time frame start/end dates
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

// Stores reference on maximum number of messages which
// should be returned from backend
@property (nonatomic, assign) NSUInteger limit;

// Stores reference on whether messages should revert
// their order in response or not
@property (nonatomic, assign, getter = shouldRevertMessages) BOOL revertMessages;


@end


#pragma mark - Public interface methods

@implementation PNMessageHistoryRequest


#pragma mark - Class methods

/**
 * Returns reference on configured history download request
 * which will take into account default values for certain
 * parameters (if passed) to change itself to load full or
 * partial history
 */
+ (PNMessageHistoryRequest *)messageHistoryRequestForChannel:(PNChannel *)channel
                                                        from:(NSDate *)startDate
                                                          to:(NSDate*)endDate
                                                       limit:(NSUInteger)limit
                                              reverseHistory:(BOOL)shouldReverseMessagesInResponse {

    return [[[self class] alloc] initForChannel:channel
                                           from:startDate
                                             to:endDate
                                          limit:limit
                                 reverseHistory:shouldReverseMessagesInResponse];
}


#pragma mark - Instance methods

/**
 * Returns reference on initialized request which will take
 * into account all special cases which depends on the values
 * which is passed to it
 */
- (id)initForChannel:(PNChannel *)channel
                from:(NSDate *)startDate
                  to:(NSDate*)endDate
               limit:(NSUInteger)limit
      reverseHistory:(BOOL)shouldReverseMessagesInResponse {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.channel = channel;
        self.startDate = startDate;
        self.endDate = endDate;
        self.limit = limit;
        self.revertMessages = shouldReverseMessagesInResponse;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.messageHistoryCallback;
}

- (NSString *)resourcePath {

    // Composing parameters list
    NSMutableString *parameters = [NSMutableString stringWithFormat:@"?callback=%@_%@",
                                                                    [self callbackMethodName],
                                                                    self.shortIdentifier];

    // Swap dates if user specified them in wrong order
    if (self.startDate && self.endDate && [self.endDate compare:self.startDate] == NSOrderedAscending) {

        NSDate *date = self.startDate;
        self.startDate = self.endDate;
        self.endDate = date;
    }

    // Checking whether user specified start/end date(s) which can be used
    // to set message history time frame or not
    if (self.startDate) {

        [parameters appendFormat:@"&start=%@", PNStringFromUnsignedLongLongNumber(PNTimeTokenFromDate(self.startDate))];
    }
    if (self.endDate) {

        [parameters appendFormat:@"&end=%@", PNStringFromUnsignedLongLongNumber(PNTimeTokenFromDate(self.endDate))];
    }

    // Check whether user specified limit or not
    self.limit = self.limit > 0 ? self.limit : 100;
    [parameters appendFormat:@"&count=%u", self.limit];
    [parameters appendFormat:@"&reverse=%@", self.shouldRevertMessages?@"true":@"false"];


    return [NSString stringWithFormat:@"/v2/history/sub-key/%@/channel/%@%@",
                    [PubNub sharedInstance].configuration.subscriptionKey,
                    [self.channel escapedName],
                    parameters];
}

#pragma mark -


@end