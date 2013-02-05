//
//  UIDevice+PNAdditions.h
//  pubnub
//
//  Category was created to add few useful
//  methods.
//
//
//  Created by Sergey Mamontov on 01/29/13.
//
//


@interface UIDevice (PNAdditions)


#pragma mark Instance methods

/**
 * Retrieve current device IP address
 * (it will return nil if device is not
 * connected or didn't received IP address
 * yet)
 */
- (NSString *)networkAddress;

#pragma mark -


@end
