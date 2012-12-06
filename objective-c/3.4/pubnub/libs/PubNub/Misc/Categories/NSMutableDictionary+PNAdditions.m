//
//  NSMutableDictionary+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/6/12.
//
//

#import "NSMutableDictionary+PNAdditions.h"


#pragma mark Public interface methods

@implementation NSMutableDictionary (PNAdditions)


#pragma mark - Class methods

+ (id)dictionaryWithNonRetainedValuesAndKeys {
    
    return (__bridge_transfer NSMutableDictionary *)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
}

#pragma mark -


@end
