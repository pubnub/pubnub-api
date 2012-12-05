//
//  PNMacro.h
//  pubnub
//
//  This helper header stores useful C functions
//  and small amount of macro for variaty of tasks.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#ifndef PNMacro_h
#define PNMacro_h

#pragma mark - Logging
#ifdef DEBUG
    #define PNLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
    #define PNLog(...) ((void)0)
#endif


static NSString* newUniqueClientIdentifier();
static NSString* newUniqueClientIdentifier() {

    // Generating new unique identifier
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // Transfering controll over CoreFundation instance to the ARC
    // (it will manage memory for us)
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    
    
    return uuidString;
}


#endif
