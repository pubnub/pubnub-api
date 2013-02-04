//
//  PNReachability.m
//  pubnub
//
//  This class helps PubNub client to monitor
//  PubNub services reachability.
//  WARNING: It is designed only for internal
//           PubNub client library usage.
//
//
//  Created by Sergey Mamontov on 12/7/12.
//
//

#import "PNReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "PubNub+Protected.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "PNMacro.h"


#pragma mark Structures

typedef enum _PNReachabilityStatus {
    
    // PubNub services reachability wasn't tested
    // yet
    PNReachabilityStatusUnknown,
    
    // PubNub services can't be reached at this moment
    // (looks like network/internet failure occurred)
    PNReachabilityStatusNotReachable,

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // PubNub service is reachable over cellular channel
    // (EDGE or 3G)
    PNReachabilityStatusReachableViaCellular,
#endif
    
    // PubNub services is available over WiFi
    PNReachabilityStatusReachableViaWiFi
} PNReachabilityStatus;


#pragma mark Private interface methods

@interface PNReachability ()


#pragma mark - Properties

@property (nonatomic, assign) SCNetworkConnectionFlags reachabilityFlags;
@property (nonatomic, assign) PNReachabilityStatus status;
@property (nonatomic, assign) SCNetworkReachabilityRef serviceReachability;


@end


#pragma mark - Public interface methods

@implementation PNReachability


#pragma mark - Class methods

+ (PNReachability *)serviceReachability {
    
    return [[[self class] alloc] init];
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.status = PNReachabilityStatusUnknown;
        
        
        // Subscribe for reachability monitor state changes observing
        [self addObserver:self
               forKeyPath:@"status"
                  options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
                  context:nil];
    }
    
    
    return self;
}


#pragma mark - Monitor activity management methods

/**
 * Helper methods for reachability status flags convertion into
 * human-readable version
 */
static PNReachabilityStatus PNReachabilityStatusForFlags(SCNetworkReachabilityFlags flags);
PNReachabilityStatus PNReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    
    PNReachabilityStatus status = PNReachabilityStatusUnknown;
    
    
    // Check whether service origin can be reached with
    // current network configuration or not
    BOOL isServiceReachable = ((flags&kSCNetworkReachabilityFlagsReachable) != 0);
    
    // Check whether service origin can be reached right
    // now or connection is required (device can connect
    // for cellular/WiFi network)
    BOOL requiresConnection = ((flags&kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    
    
    // Check whether service can be reached right not or not
    if (isServiceReachable && !requiresConnection) {
        
        status = PNReachabilityStatusReachableViaWiFi;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        // Check whether service origin can be reached over
        // cellular channel of hand-held devices or not
        if ((flags&kSCNetworkReachabilityFlagsIsWWAN) != 0) {
            
            status = PNReachabilityStatusReachableViaCellular;
        }
#endif
    }
    else {
        
        status = PNReachabilityStatusNotReachable;
    }
    
    
    return status;
}

/**
 * This is reachability callback method which will be called by
 * system network subsystem each time when it notice that remote
 * service changed it's reachability state
 */
static void PNReachabilityCallback(SCNetworkReachabilityRef reachability, SCNetworkReachabilityFlags flags, void *info);
void PNReachabilityCallback(SCNetworkReachabilityRef reachability, SCNetworkReachabilityFlags flags, void *info) {
    
    // Verify that reachability callback was called for correct client
    NSCAssert([(__bridge NSObject *)info isKindOfClass:[PNReachability class]],
              @"Wrong instance has been sent as reachability observer");
    
    
    // Retrieve reference on reachability monitor and update it's state
    PNReachability *reachabilityMonitor = (__bridge PNReachability *)info;
    reachabilityMonitor.reachabilityFlags = flags;
    reachabilityMonitor.status = PNReachabilityStatusForFlags(reachabilityMonitor.reachabilityFlags);
}

- (void)startServiceReachabilityMonitoring {
    
    [self stopServiceReachabilityMonitoring];
    
    
    // Check whether origin (PubNub services host) is specified or not
    NSString *originHost = [PubNub sharedInstance].configuration.origin;
    if (originHost == nil) {
        
        return;
    }
    
    
    // Prepare and configure reachability monitor
    self.serviceReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [originHost UTF8String]);
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    if(SCNetworkReachabilitySetCallback(self.serviceReachability, PNReachabilityCallback, &context)) {
        
        // Schedule service reachability monitoring on current runloop with
        // common mode (prevent from blocking by other tasks)
        SCNetworkReachabilityScheduleWithRunLoop(self.serviceReachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    
    
    struct sockaddr_in addressIPv4;
    struct sockaddr_in6 addressIPv6;
    char *serverCString = (char *)[originHost UTF8String];
    if (inet_pton(AF_INET, serverCString, &addressIPv4) == 1 || inet_pton(AF_INET6, serverCString, &addressIPv6)) {
        
        SCNetworkReachabilityFlags currentReachabilityStateFlags;
        SCNetworkReachabilityGetFlags(self.serviceReachability, &currentReachabilityStateFlags);
        self.status = PNReachabilityStatusForFlags(currentReachabilityStateFlags);
    }


    PNLog(PNLogGeneralLevel, self, @"START REACHABILITY OBSERVATION");
}

- (void)stopServiceReachabilityMonitoring {
    
    // Check whether reachability instance crated
    // before destroy it
    if (self.serviceReachability) {
        
        SCNetworkReachabilityUnscheduleFromRunLoop(self.serviceReachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFRelease(_serviceReachability);
        _serviceReachability = NULL;
    }
    
    
    // Reset reachability status
    self.status = PNReachabilityStatusUnknown;


    PNLog(PNLogGeneralLevel, self, @"STOP REACHABILITY OBSERVATION");
}


#pragma mark - Handler methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // Retrieved changed values (old/new)
    PNReachabilityStatus newStatus = (PNReachabilityStatus)[[change valueForKey:NSKeyValueChangeNewKey] intValue];
    PNReachabilityStatus oldStatus = (PNReachabilityStatus)[[change valueForKey:NSKeyValueChangeOldKey] intValue];
    
    // Checking whether service reachability
    // really changed or not
    if(oldStatus != newStatus) {
        
        if (newStatus != PNReachabilityStatusUnknown) {
            
            PNLog(PNLogReachabilityLevel, self, @" PubNub services reachability changed [CONNECTED? %@]", [self isServiceAvailable]?@"YES":@"NO");
            
            if (self.reachabilityChangeHandleBlock) {
                
                self.reachabilityChangeHandleBlock([self isServiceAvailable]);
            }
        }
        else {
            
            // Reset reachability status to old
            _status = oldStatus;
        }
    }
}


#pragma mark - Misc methods

- (BOOL)isServiceReachabilityChecked {
    
    return self.status != PNReachabilityStatusUnknown;
}

- (BOOL)isServiceAvailable {
    
    return (self.status == PNReachabilityStatusReachableViaCellular ||
            self.status == PNReachabilityStatusReachableViaWiFi);
    
}


#pragma mark - Memory management

- (void)dealloc {
    
    // Clean up
    [self stopServiceReachabilityMonitoring];
    [self removeObserver:self forKeyPath:@"status"];
}

#pragma mark -


@end
