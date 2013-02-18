//
//  PNConfiguration+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 02/18/13.
//
//

#import "PNConfiguration.h"


@interface PNConfiguration (Protected)


#pragma mark Instance methods

/**
 * Set whether configuration should provide DNS killing
 * remote origin address or not
 */
- (void)shouldKillDNSCache:(BOOL)shouldKillDNSCache;

#pragma mark -


@end