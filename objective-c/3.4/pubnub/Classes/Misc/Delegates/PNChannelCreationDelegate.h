//
//  PNChannelCreationDelegate.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#pragma mark Class forward

@class PNChannelCreationView, PNChannel;


@protocol PNChannelCreationDelegate <NSObject>

@required

/**
 * Called on delegate when user hit "Subscribe"
 * button in interface
 */
- (void)creationView:(PNChannelCreationView*)view subscribeOnChannel:(PNChannel *)channel;

#pragma mark -


@end