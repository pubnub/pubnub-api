//
//  PNDelegate.h
//  pubnub
//
//  Base PubNub client delegation protocol
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub, PNError;


@protocol PNDelegate <NSObject>

/**
 * Called on delegate when client successfully connected to the
 * origin and perfomed initial calls (calls which update presence on server)
 */
- (void)pubnubClient:(PubNub *)client didConnectedToOrigin:(NSString *)origin;

/**
 * Called on delegate when some kind of error occurred during 
 * subscription creation
 * error - returned error will contain information about channel
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;

@end
