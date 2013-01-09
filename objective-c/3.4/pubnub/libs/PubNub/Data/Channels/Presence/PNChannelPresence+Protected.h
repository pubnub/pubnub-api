//
//  PNChannelPresence+Protected.h
//  pubnub
//
//  This header helps to hide part of presencd
//  channel implementation from public access
//
//  Created by Sergey Mamontov on 12/25/12.
//
//
#import "PNChannelPresence.h"


#pragma mark Static

// Stores reference on suffix which is used
// to mark channel as presence observer for
// another channel
static NSString * const kPNPresenceObserverChannelSuffix = @"-pnpres";

