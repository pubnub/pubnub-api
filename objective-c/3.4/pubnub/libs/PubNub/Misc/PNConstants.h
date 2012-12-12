//
//  PNConstants.h
//  pubnub
//
//  This header is used to store set of
//  PubNub constants which will be used
//  all other the library.
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#ifndef PNConstants_h
#define PNConstants_h

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSString * const kPNDefaultOriginHost = @"ios.pubnub.com";
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
static NSString * const kPNDefaultOriginHost = @"macos.pubnub.com";
#endif
static BOOL const kPNSecureConnectionByDefault = YES;

// Stores client library version number
static NSString * const kPNClientVersion = @"3.4";

// Stores resource path prefix which will allow to change
// API version on the flight
static NSString * const kPNRequestAPIVersionPrefix = @"";

#endif // PNConstants_h
