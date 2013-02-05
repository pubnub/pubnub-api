//
//  PNChannelInformationView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import "PNChannelInformationDelegate.h"


@interface PNChannelInformationView : UIView


#pragma mark Properties

@property (nonatomic, pn_desired_weak) id<PNChannelInformationDelegate> delegate;

#pragma mark -

/**
 * Help to present view and hide it
 */
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end