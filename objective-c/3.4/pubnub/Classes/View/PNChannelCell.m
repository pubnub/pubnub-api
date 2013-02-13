//
//  PNChannelCell.m
//  pubnub
//
//  Created by Sergey Mamontov on 02/06/13.
//
//

#import "PNChannelCell.h"
#import "PNDataManager.h"
#import "PNChannel.h"


#pragma mark - Public interface methods

@implementation PNChannelCell


#pragma mark - Instance methods

- (void)updateForChannel:(PNChannel *)channel {

    NSUInteger eventsCount = [[PNDataManager sharedInstance] numberOfEventsForChannel:channel];
    NSString *prefix = @"";
    if (eventsCount > 0) {

        prefix = [NSString stringWithFormat:@" [%i]", eventsCount];
    }

    self.textLabel.text = [NSString stringWithFormat:@"%@%@", channel.name, prefix];
}

#pragma mark -


@end
