//
//  SubcribeInBackground.h
//  Pubnub
//
//  Created by itshastra on 27/11/12.
//
//

#import <Foundation/Foundation.h>
#import "CEPubnubDelegate.h"
#import "PubNub/CEPubnub.h"
@interface PubnubDelegate : NSObject<CEPubnubDelegate>
@end

@interface SubcribeInBackground : NSOperation
     @property(retain) PubnubDelegate *__delegate;
@end
