//
//  CL_81.h
//  CocoaPubnubTest
//
//  Created by itshastra on 18/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEPubnubDelegate.h"

@interface CL_81 : NSObject <CEPubnubDelegate>

- (void) publishMessage;
- (void) getHistory;
- (void) getTime;
- (void) getUUID;
- (void) subscribe;
- (void) unsubscribe;
- (void) here_now;

@end