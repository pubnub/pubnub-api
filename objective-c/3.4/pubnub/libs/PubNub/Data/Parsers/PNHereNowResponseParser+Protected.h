//
//  PNHereNowResponseParser+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#ifndef _PNHereNowParser_Protected
#define _PNHereNowParser_Protected

// Stores reference on key under which list of unique
// user identifiers in channel is stored
static NSString * const kPNResponseUUIDKey = @"uuids";

// Stores reference on key under which number of participants
// in room is stored
static NSString * const kPNResponseOccupancyKey = @"occupancy";

#endif
