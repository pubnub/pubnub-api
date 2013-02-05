//
//  NSMutableArray+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/16/12.
//
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (PNAdditions)


#pragma mark - Class methods

/**
 * Returns array which wouldn't retain it's
 * values
 */
+ (NSMutableArray *)arrayUsingWeakReferences;

/**
 * Returns array which wouldn't retain it's
 * values
 */
+ (NSMutableArray *)arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

#pragma mark -


@end
