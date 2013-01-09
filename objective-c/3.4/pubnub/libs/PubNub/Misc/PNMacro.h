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

#import <Foundation/Foundation.h>


#ifndef PNMacro_h
#define PNMacro_h 1


#pragma mark - Weaks

#ifndef pn_desired_weak
    #if __has_feature(objc_arc_weak)
        #define pn_desired_weak weak
        #define __pn_desired_weak __weak
    #else
        #define pn_desired_weak unsafe_unretained
        #define __pn_desired_weak __unsafe_unretained
    #endif
#endif


#pragma mark - Logging

#define PNLOG_GENERAL_LOGGING_ENABLED 1
#define PNLOG_REACHABILITY_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 1

typedef enum _PNLogLevels {
    PNLogGeneralLevel,
    PNLogReachabilityLevel,
    PNLogConnectionLayerErrorLevel,
    PNLogConnectionLayerInfoLevel,
    PNLogCommunicationChannelLayerErrorLevel,
    PNLogCommunicationChannelLayerWarnLevel,
    PNLogCommunicationChannelLayerInfoLevel
} PNLogLevels;


static void PNLog(PNLogLevels level, id sender, ...);
void PNLog(PNLogLevels level, id sender, ...) {

    __block __pn_desired_weak id weakSender = sender;
    NSString *formattedLog = nil;

    va_list args;
    va_start(args, sender);
    NSString *logFormatString = va_arg(args, NSString*);
    NSString *formattedLogString = [[NSString alloc] initWithFormat:logFormatString arguments:args];
    va_end(args);

    formattedLog = [NSString stringWithFormat:@"(%p) %%@%@", weakSender, formattedLogString];
    NSString *additionalData = nil;

    if ((level == PNLogGeneralLevel && PNLOG_GENERAL_LOGGING_ENABLED) ||
        (level == PNLogReachabilityLevel && PNLOG_REACHABILITY_LOGGING_ENABLED)) {

        additionalData = @"";
    }
    else if ((level == PNLogConnectionLayerInfoLevel && PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED) ||
             (level == PNLogCommunicationChannelLayerInfoLevel && PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED)) {

        additionalData = @"{INFO}";
    }
    else if ((level == PNLogConnectionLayerErrorLevel && PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED) ||
             (level == PNLogCommunicationChannelLayerErrorLevel && PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED)) {

        additionalData = @"{ERROR}";
    }
    else if (level == PNLogCommunicationChannelLayerWarnLevel && PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED) {

        additionalData = @"{WARN}";
    }


    if(formattedLog != nil && additionalData != nil) {

        NSLog([NSString stringWithFormat:formattedLog, additionalData]);
    }
}


static void PNCFRelease(CFTypeRef cfobject);
void PNCFRelease(CFTypeRef cfobject) {

    if (cfobject != NULL) {

        CFRelease(cfobject);
        cfobject = NULL;
    }
}

static NSUInteger PNRandomValueInRange(NSRange valuesRange);
NSUInteger PNRandomValueInRange(NSRange valuesRange) {
    
    return valuesRange.location + (random() % (valuesRange.length - valuesRange.location));
}

static NSString* PNUniqueIdentifier();
NSString* PNUniqueIdentifier() {

    // Generating new unique identifier
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfUUID = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);

    
    return [(NSString *)CFBridgingRelease(cfUUID) lowercaseString];
}

static NSString* PNShortenedIdentifierFromUUID(NSString *uuid);
NSString* PNShortenedIdentifierFromUUID(NSString *uuid) {
    
    NSMutableString *shortenedUUID = [NSMutableString string];
    
    NSArray *components = [uuid componentsSeparatedByString:@"-"];
    [components enumerateObjectsUsingBlock:^(NSString *group, NSUInteger groupIdx, BOOL *groupEnumeratorStop) {
        
        NSRange randomValueRange = NSMakeRange(PNRandomValueInRange(NSMakeRange(0, [group length])), 1);
        [shortenedUUID appendString:[group substringWithRange:randomValueRange]];
    }];
    
    
    return shortenedUUID;
}


#endif
