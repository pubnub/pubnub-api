//
//  PNHereNowResponseParser+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/15/13.
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
