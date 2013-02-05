//
//  PNChannelCreationView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import <Foundation/Foundation.h>
#import "PNChannelCreationDelegate.h"
#import "PNShadowEnableView.h"


@interface PNChannelCreationView : PNShadowEnableView


#pragma mark Properties

// Stores reference on delegate which will be used to
// notify about subscription attempt
@property (nonatomic, pn_desired_weak) id<PNChannelCreationDelegate> delegate;


#pragma mark - Class methods

/**
 * Allow to load instance from NIB file
 */
+ (id)viewFromNib;

#pragma mark -


@end