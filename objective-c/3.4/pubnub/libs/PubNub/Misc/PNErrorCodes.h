//
//  PNErrorCodes.h
//  pubnub
//
//  Describes all available error codes
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

// PubNub client initialization failure
// Possible reasons are:
//   - identifier already taken by someone else
//   - request time out
//   - response parsing error
static NSInteger const kPNInitializationErrorCode = 100;