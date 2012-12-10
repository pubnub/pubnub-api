//
//  PubNub+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import "PNConfiguration.h"
#import "PNDelegate.h"
#import "PubNub.h"


@interface PubNub (Protected)


#pragma mark - Properties

// Stores reference on configuration which was used to
// perform intial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;


#pragma mark -


@end