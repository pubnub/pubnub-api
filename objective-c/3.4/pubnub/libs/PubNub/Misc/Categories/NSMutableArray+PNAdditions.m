//
//  NSMutableArray+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/16/12.
//
//

#import "NSMutableArray+PNAdditions.h"


#pragma mark Public interface methods

@implementation NSMutableArray (PNAdditions)


#pragma mark - Class methods

+ (NSMutableArray *)arrayUsingWeakReferences {
    
    return [self arrayUsingWeakReferencesWithCapacity:0];
}

+ (NSMutableArray *)arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    
    CFArrayCallBacks callbacks = {0, NULL, NULL, NULL, CFEqual};
    
    
    return (__bridge id)(CFArrayCreateMutable(0, capacity, &callbacks));
}

#pragma mark -


@end
