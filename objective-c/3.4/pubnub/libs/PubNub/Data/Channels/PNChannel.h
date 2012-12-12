//
//  PNChannel.h
//  pubnub
//
//  Represents object which is used to subscribe
//  for channels and presence.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import <Foundation/Foundation.h>


@interface PNChannel : NSObject


#pragma mark Properties

// Channel name
@property (nonatomic, copy) NSString *name;

// Last state update time
@property (nonatomic, copy) NSString *updateTimeToken;


#pragma mark - Instance methods

- (void)resetUpdateTimeToken;

#pragma mark -


@end
