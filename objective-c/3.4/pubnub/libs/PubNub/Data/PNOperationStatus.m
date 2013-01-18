//
//  PNOperationStatus.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

#import "PNOperationStatus+Protected.h"


#pragma mark Private interface methods

@interface PNOperationStatus ()


#pragma mark - Properties

@property (nonatomic, getter = isSuccessful) BOOL successful;
@property (nonatomic, strong) PNError *error;
@property (nonatomic, copy) NSString *statusDescription;
@property (nonatomic, strong) NSNumber *timeToken;


@end


#pragma mark - Public interface methods

@implementation PNOperationStatus


#pragma mark - Instance methods

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p) <successful: %@, time token: %@, description: %@, error: %@>",
                    NSStringFromClass([self class]),
                    self, self.isSuccessful?@"YES":@"NO",
                    self.timeToken,
                    self.statusDescription,
                    self.error];
}

#pragma mark -


@end