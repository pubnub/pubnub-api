//
//  PNShadowEnableView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import "PNShadowEnableView.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Public interface methods

@implementation PNShadowEnableView


#pragma mark - Instance methods

- (void)awakeFromNib {

    // Forward to the super class to complete initializations
    [super awakeFromNib];

    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f].CGColor;
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark -


@end