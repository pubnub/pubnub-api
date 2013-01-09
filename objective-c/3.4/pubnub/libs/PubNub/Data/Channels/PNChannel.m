//
//  PNChannel.m
//  pubnub
//
//  Represents object which is used to subscribe
//  for channels and presence.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNChannel+Protected.h"


#pragma mark Static

static NSMutableDictionary *_channelsCache = nil;


#pragma mark - Private interface methods

@interface PNChannel ()


#pragma mark - Properties

// Channel name
@property (nonatomic, copy) NSString *name;

// Last state update time
@property (nonatomic, copy) NSString *updateTimeToken;

// Stores number of participants for particular
// channel (this number fetched from presence API
// if it is used and updated when requested list
// of participants)
// INFO: it may differ in count from participants
//       name because of nature of this value
//       update logic
@property (nonatomic, assign) NSUInteger participantsCount;

// Stores list of participants names for particular
// channel (updated and initially filled only by
// participants list request)
@property (nonatomic, strong) NSMutableArray *participantsList;

// Stores whether channel presence observation is required
@property (nonatomic, assign, getter = shouldObservePresence) BOOL observePresence;


#pragma mark - Class methods

+ (NSDictionary *)channelsCache;


#pragma mark - Instance methods

/**
 * Return initialized channel instance with specified name
 * (if name already was used during client connection session
 * when instance will be pulled out from cache).
 */
- (id)initWithName:(NSString *)channelName;


@end


#pragma mark - Public interface methods

@implementation PNChannel


#pragma mark - Class methods

+ (NSArray *)channelsWithNames:(NSArray *)channelsName {

    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[channelsName count]];

    [channelsName enumerateObjectsUsingBlock:^(NSString *channelName,
                                               NSUInteger channelNameIdx,
                                               BOOL *channelNamesEnumerator) {

        [channels addObject:[PNChannel channelWithName:channelName]];
    }];


    return channels;
}

+ (PNChannel *)channelWithName:(NSString *)channelName {
    
    return [self channelWithName:channelName shouldObservePresence:NO];
}

+ (PNChannel *)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence {
    
    PNChannel *channel = [[[self class] channelsCache] valueForKey:channelName];
    
    if (channel == nil) {
        
        channel = [[[self class] alloc] initWithName:channelName];
        channel.observePresence = observePresence;
        [[[self class] channelsCache] setValue:channel forKey:channelName];
    }
    
    
    return channel;
}

+ (void)purgeChannelsCache {
    
    @synchronized(self) {
        
        if([_channelsCache count] > 0) {
            
            [_channelsCache removeAllObjects];
        }
    }
}

+ (NSDictionary *)channelsCache {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _channelsCache = [NSMutableDictionary dictionary];
    });
    
    
    return _channelsCache;
}


#pragma mark - Instance methods

- (id)initWithName:(NSString *)channelName {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        [self resetUpdateTimeToken];
        self.name = channelName;
        self.participantsList = [NSMutableArray array];
    }
    
    
    return self;
}

- (PNChannelPresence *)presenceObserver {
    
    PNChannelPresence *presence = nil;
    if (self.shouldObservePresence) {
        
        presence = [PNChannelPresence presenceForChannel:self];
    }
    
    
    return presence;
}

- (void)resetUpdateTimeToken {
    
    self.updateTimeToken = @"0";
}

- (NSArray *)participants {
    
    return self.participantsList;
}

- (NSString *)escapedName {

    return [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -


@end
