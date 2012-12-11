//
//  PNConnectionChannel.h
//  pubnub
//
//  Connection channel is intermediate class
//  between transport network layer and other
//  library classes.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionChannel+Protected.h"
#import "PNConnectionDelegate.h"


@interface PNConnectionChannel : NSObject <PNConnectionDelegate>


#pragma mark Class methods

/**
 * Returns reference on fully configured channel which is 
 * ready to be connected and usage
 */
+ (PNConnectionChannel *)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType;


#pragma mark - Instance methods

/**
 * Initialize connection channel which on it's own will
 * initiate socket connection with streams
 */
- (id)initWithType:(PNConnectionChannelType)connectionChannelType;

#pragma mark -


@end
