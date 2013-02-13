//
//  PNChannelInformationDelegate.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


@protocol PNChannelInformationDelegate <NSObject>

@required

/**
 * Send to the delegate when client hit on
 * "View channel history" button
 */
- (void)showHistoryRequestParameters;

#pragma mark -


@end