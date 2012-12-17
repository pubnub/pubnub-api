//
//  PNViewController.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNViewController.h"


#pragma mark Private interface methods

@interface PNViewController ()

@end


#pragma mark - Public interface methods

@implementation PNViewController


#pragma mark - Instance methods

/**
 * Asking view controller whether interface will be rotated to portrait
 * orientation or not
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}


#pragma mark -


@end
