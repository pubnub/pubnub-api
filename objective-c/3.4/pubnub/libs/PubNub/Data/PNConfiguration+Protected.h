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

/**
 * Check whether PubNub client should reset connection
 * because new configuration instance changed critical
 * parts of configuration or not
 */
- (BOOL)requiresConnectionResetWithConfiguration:(PNConfiguration *)configuration;

/**
 * Check whether configuration is valid or not
 */
- (BOOL)isValid;

#pragma mark -


@end