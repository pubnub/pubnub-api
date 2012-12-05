//
//  PubNub+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import "PNConfiguration.h"


@interface PubNub (Protected)


#pragma mark - Properties

// Check whether PubNub client completed intialization or not
// (full initialization cycle is from configuration to time token
// retrival from PubNub services)
@property (nonatomic, assign, getter = isInitialized) BOOL initialized;

// Stores reference on configuration which was used to
// perform intial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;


#pragma mark -


@end