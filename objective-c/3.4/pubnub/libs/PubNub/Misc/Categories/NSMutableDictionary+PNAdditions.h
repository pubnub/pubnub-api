//
//  NSMutableDictionary+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/6/12.
//
//

#import <Foundation/Foundation.h>


@interface NSMutableDictionary (PNAdditions)


#pragma mark Class methods

/**
 * Retrieve reference on dictionary which douldn't
 * retain it's values and keys
 */
+ (id)dictionaryWithNonRetainedValuesAndKeys;

#pragma mark -


@end
