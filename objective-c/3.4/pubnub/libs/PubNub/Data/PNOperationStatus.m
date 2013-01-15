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


@end