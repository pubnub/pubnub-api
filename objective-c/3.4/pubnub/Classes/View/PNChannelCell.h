//
//  PNChannelCell.h
//  pubnub
//
//  Created by Sergey Mamontov on 02/06/13.
//
//

#pragma mark Class forward

@class PNChannel;


@interface PNChannelCell : UITableViewCell


#pragma mark - Instance methods

/**
 * Update cell layout to show data for specified channel
 */
- (void)updateForChannel:(PNChannel *)channel;

#pragma mark -


@end
