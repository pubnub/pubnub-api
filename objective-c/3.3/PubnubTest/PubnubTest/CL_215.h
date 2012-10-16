//
//  CL_215.h
//  PubnubTest
//
//  Created by itshastra on 16/10/12.
//
//

#import <Foundation/Foundation.h>
#import "CEPubnub.h"

@interface CL_215:NSObject<CEPubnubDelegate>
-(void) runCL_215UnitTest;
@property (strong) id<CEPubnubDelegate> delHolder;

@end
