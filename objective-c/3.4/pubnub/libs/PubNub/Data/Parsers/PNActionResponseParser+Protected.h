//
//  PNActionResponseParser+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov on 01/15/13.
//
//

#ifndef _PNActionParser_Protected
#define _PNActionParser_Protected

// Stores reference on key which stores reference on
// action name which was confirmed in response
static NSString * const kPNResponseActionKey = @"action";


#endif
