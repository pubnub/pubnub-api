//
//  PNObservationCenter.h
//  pubnub
//
//  Observation center will allow to subscribe
//  for particular events with handle block
//  (block will be provided by subscriber)
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNObservationCenter+Protected.h"
#import "PNMessagesHistory+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNError+Protected.h"
#import "PubNub+Protected.h"
#import "PNPresenceEvent.h"
#import "PNMessage.h"
#import "PNHereNow.h"


#pragma mark Static

// Stores reference on shared observation center instance
static PNObservationCenter *_sharedInstance = nil;

struct PNObservationEventsStruct {

    __unsafe_unretained NSString *clientConnectionStateChange;
    __unsafe_unretained NSString *clientSubscriptionOnChannels;
    __unsafe_unretained NSString *clientUnsubscribeFromChannels;
    __unsafe_unretained NSString *clientTimeTokenReceivingComplete;
    __unsafe_unretained NSString *clientMessageSendCompletion;
    __unsafe_unretained NSString *clientReceivedMessage;
    __unsafe_unretained NSString *clientReceivedPresenceEvent;
    __unsafe_unretained NSString *clientReceivedHistory;
    __unsafe_unretained NSString *clientReceivedParticipantsList;
};

struct PNObservationObserverDataStruct {

    __unsafe_unretained NSString *observer;
    __unsafe_unretained NSString *observerCallbackBlock;
};

static struct PNObservationEventsStruct PNObservationEvents = {
    .clientConnectionStateChange = @"clientConnectionStateChangeEvent",
    .clientTimeTokenReceivingComplete = @"clientReceivingTimeTokenEvent",
    .clientSubscriptionOnChannels = @"clientSubscribtionOnChannelsEvent",
    .clientUnsubscribeFromChannels = @"clientUnsubscribeFromChannelsEvent",
    .clientMessageSendCompletion = @"clientMessageSendCompletionEvent",
    .clientReceivedMessage = @"clientReceivedMessageEvent",
    .clientReceivedPresenceEvent = @"clientReceivedPresenceEvent",
    .clientReceivedHistory = @"clientReceivedHistoryEvent",
    .clientReceivedParticipantsList = @"clientReceivedParticipantsListEvent"
};

static struct PNObservationObserverDataStruct PNObservationObserverData = {

    .observer = @"observer",
    .observerCallbackBlock = @"observerCallbackBlock"
};


#pragma mark - Private interface methods

@interface PNObservationCenter ()


#pragma mark - Properties

// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
@property (nonatomic, strong) NSMutableDictionary *observers;

// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
// This is FIFO observer type which means that as soon as event
// will occur observer will be removed from list
@property (nonatomic, strong) NSMutableDictionary *oneTimeObservers;


#pragma mark - Instance methods

/**
 * Helper methods which will create collection for specified
 * event name if it doesn't exist or return existing.
 */
- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName;
- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName;

- (void)removeOneTimeObserversForEvent:(NSString *)eventName;

/**
 * Managing observation list
 */
- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block;
- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent;


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification;
- (void)handleClientSubscriptionProcess:(NSNotification *)notification;
- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification;
- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification;
- (void)handleClientDidReceiveMessage:(NSNotification *)notification;
- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification;
- (void)handleClientMessageHistoryProcess:(NSNotification *)notification;
- (void)handleClientHereNowProcess:(NSNotification *)notification;
- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification;


#pragma mark - Misc methods

/**
 * Retrieve full list of observers for specified event name
 */
- (NSMutableArray *)observersForEvent:(NSString *)eventName;


@end


#pragma mark - Public interface methods

@implementation PNObservationCenter


#pragma mark Class methods

+ (id)defaultCenter {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
    
    
    return _sharedInstance;
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.observers = [NSMutableDictionary dictionary];
        self.oneTimeObservers = [NSMutableDictionary dictionary];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientConnectionStateChange:)
                                                     name:kPNClientDidConnectToOriginNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientConnectionStateChange:)
                                                     name:kPNClientDidDisconnectFromOriginNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientConnectionStateChange:)
                                                     name:kPNClientConnectionDidFailWithErrorNotification
                                                   object:nil];
        
        
        // Handle subscription events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientSubscriptionProcess:)
                                                     name:kPNClientSubscriptionDidCompleteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientSubscriptionProcess:)
                                                     name:kPNClientSubscriptionWillRestoreNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientSubscriptionProcess:)
                                                     name:kPNClientSubscriptionDidRestoreNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientSubscriptionProcess:)
                                                     name:kPNClientSubscriptionDidFailNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientUnsubscriptionProcess:)
                                                     name:kPNClientUnsubscriptionDidCompleteNotification
                                                   object:nil];


        // Handle time token events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                                     name:kPNClientDidReceiveTimeTokenNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                                     name:kPNClientDidFailTimeTokenReceiveNotification
                                                   object:nil];


        // Handle message processing events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientMessageProcessingStateChange:)
                                                     name:kPNClientWillSendMessageNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientMessageProcessingStateChange:)
                                                     name:kPNClientDidSendMessageNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientMessageProcessingStateChange:)
                                                     name:kPNClientMessageSendingDidFailNotification
                                                   object:nil];

        // Handle messages/presence event arrival
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientDidReceiveMessage:)
                                                     name:kPNClientDidReceiveMessageNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientDidReceivePresenceEvent:)
                                                     name:kPNClientDidReceivePresenceEventNotification
                                                   object:nil];

        // Handle message history events arrival
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientMessageHistoryProcess:)
                                                     name:kPNClientDidReceiveMessagesHistoryNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientMessageHistoryProcess:)
                                                     name:kPNClientHistoryDownloadFailedWithErrorNotification
                                                   object:nil];

        // Handle participants list arrival
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientHereNowProcess:)
                                                     name:kPNClientDidReceiveParticipantsListNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientHereNowProcess:)
                                                     name:kPNClientParticipantsListDownloadFailedWithErrorNotification
                                                   object:nil];
        
        
    }
    
    
    return self;
}

- (BOOL)isSubscribedOnClientStateChange:(id)observer {

    NSMutableArray *observersData = [self oneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
    NSArray *observers = [observersData valueForKey:PNObservationObserverData.observer];


    return [observers containsObject:observer];
}

- (void)removeOneTimeObserversForEvent:(NSString *)eventName {

    [self.oneTimeObservers removeObjectForKey:eventName];
}

- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block {

    NSDictionary *observerData = @{PNObservationObserverData.observer:observer,
                      PNObservationObserverData.observerCallbackBlock:block};

    // Retrieve reference on list of observers for specific event
    SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

    // Turn off error warning on performSelector, because ARC
    // can't understand what is goingon there
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
    #pragma clang diagnostic pop

    [observers addObject:observerData];
}

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent {

    // Retrieve reference on list of observers for specific event
    SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

    // Turn off error warning on performSelector, because ARC
    // can't understand what is goingon there
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
    #pragma clang diagnostic pop

    // Retrieve list of observing requests with specified observer
    NSString *filterFormat = [NSString stringWithFormat:@"%@ = %%@", PNObservationObserverData.observer];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterFormat, observer];

    NSArray *filteredObservers = [observers filteredArrayUsingPredicate:filterPredicate];


    if ([filteredObservers count] > 0) {

        // Removing first occurrence of observer request in list
        [observers removeObject:[filteredObservers objectAtIndex:0]];
    }
}


#pragma mark - Client connection state observation

- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addClientConnectionStateObserver:observer oneTimeEvent:NO withCallbackBlock:callbackBlock];
}

- (void)removeClientConnectionStateObserver:(id)observer {

    [self removeClientConnectionStateObserver:observer oneTimeEvent:NO];
}

- (void)addClientConnectionStateObserver:(id)observer
                            oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientConnectionStateChange
         oneTimeEvent:isOneTimeEventObserver
            withBlock:callbackBlock];

}

- (void)removeClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientConnectionStateChange
            oneTimeEvent:isOneTimeEventObserver];
}


#pragma mark - Client channels action/event observation

- (void)addClientChannelSubscriptionStateObserver:(id)observer

                           withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeClientChannelSubscriptionStateObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientSubscriptionOnChannels oneTimeEvent:NO];
}

- (void)addClientChannelUnsubscriptionObserver:(id)observer
                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeClientChannelUnsubscriptionObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:NO];
}


#pragma mark - Subscription observation

- (void)addClientAsSubscriptionObserverWithBlock:(PNClientChannelSubscriptionHandlerBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsSubscriptionObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientSubscriptionOnChannels
            oneTimeEvent:YES];
}

- (void)addClientAsUnsubscribeObserverWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsUnsubscribeObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientUnsubscribeFromChannels
            oneTimeEvent:YES];
}


#pragma mark - Time token observation

- (void)addClientAsTimeTokenReceivingObserverWithCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsTimeTokenReceivingObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
            oneTimeEvent:YES];
}

- (void)addTimeTokenReceivingObserver:(id)observer
                    withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeTimeTokenReceivingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientTimeTokenReceivingComplete oneTimeEvent:NO];
}


#pragma mark - Message sending observers

- (void)addClientAsMessageProcessingObserverWithBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addMessageProcessingObserver:[PubNub sharedInstance] withBlock:handleBlock oneTimeEvent:YES];

}
- (void)removeClientAsMessageProcessingObserver {

    [self removeMessageProcessingObserver:[PubNub sharedInstance] oneTimeEvent:YES];
}

- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addMessageProcessingObserver:observer withBlock:handleBlock oneTimeEvent:NO];
}

- (void)removeMessageProcessingObserver:(id)observer {

    [self removeMessageProcessingObserver:observer oneTimeEvent:NO];
}

- (void)addMessageProcessingObserver:(id)observer
                           withBlock:(PNClientMessageProcessingBlock)handleBlock
                        oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientMessageSendCompletion
         oneTimeEvent:isOneTimeEventObserver
            withBlock:handleBlock];
}

- (void)removeMessageProcessingObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientMessageSendCompletion
            oneTimeEvent:isOneTimeEventObserver];
}

- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedMessage
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removeMessageReceiveObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedMessage
            oneTimeEvent:NO];
}


#pragma mark - Presence observing

- (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedPresenceEvent
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removePresenceEventObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedPresenceEvent
            oneTimeEvent:NO];
}


#pragma mark - History observers

- (void)addClientAsHistoryDownloadObserverWithBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsHistoryDownloadObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:YES];
}

- (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removeMessageHistoryProcessingObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:NO];
}


#pragma mark - Participants observer

- (void)addClientAsParticipantsListDownloadObserverWithBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:YES
            withBlock:handleBlock];

}

- (void)removeClientAsParticipantsListDownloadObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientReceivedParticipantsList
            oneTimeEvent:NO];
}


#pragma mark - Participants observing

- (void)addChannelParticipantsListProcessingObserver:(id)observer
                                           withBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removeChannelParticipantsListProcessingObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedParticipantsList
            oneTimeEvent:NO];
}


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
    
    // Default field values
    BOOL connected = YES;
    PNError *connectionError = nil;
    NSString *origin = [PubNub sharedInstance].configuration.origin;
    
    if([notification.name isEqualToString:kPNClientDidConnectToOriginNotification] ||
       [notification.name isEqualToString:kPNClientDidDisconnectFromOriginNotification]) {
        
        origin = (NSString *)notification.userInfo;
        connected = [notification.name isEqualToString:kPNClientDidConnectToOriginNotification];
    }
    else if([notification.name isEqualToString:kPNClientConnectionDidFailWithErrorNotification]) {
        
        connected = NO;
        connectionError = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientConnectionStateChange];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientConnectionStateChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(origin, connected, connectionError);
        }
    }];


    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
}

- (void)handleClientSubscriptionProcess:(NSNotification *)notification {


    NSArray *channels = nil;
    PNError *error = nil;
    PNSubscriptionProcessState state = PNSubscriptionProcessNotSubscribedState;

    // Check whether arrived notification that subscription failed or not
    if ([notification.name isEqualToString:kPNClientSubscriptionDidFailNotification]) {

        error = (PNError *)notification.userInfo;
        channels = error.associatedObject;
    }
    else {

        // Retrieve list of channels on which event is occurred
        channels = (NSArray *)notification.userInfo;
        state = PNSubscriptionProcessSubscribedState;

        // Check whether arrived notification that subscription will be restored
        if ([notification.name isEqualToString:kPNClientSubscriptionWillRestoreNotification]) {

            state = PNSubscriptionProcessWillRestoreState;
        }
        // Check whether arrived notification that subscription restored
        else if ([notification.name isEqualToString:kPNClientSubscriptionDidRestoreNotification]) {

            state = PNSubscriptionProcessRestoredState;
        }
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientSubscriptionOnChannels];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelSubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(state, channels, error);
        }
    }];


    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientSubscriptionOnChannels];
}

- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification {

    // Retrieve reference on list of channels
    NSArray *channels = (NSArray *)notification.userInfo;


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientUnsubscribeFromChannels];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelUnsubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, nil);
        }
    }];


    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientUnsubscribeFromChannels];
}

- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification {

    PNMessageState state = PNMessageSending;
    id processingData = nil;
    BOOL shouldUnsubscribe = NO;
    if ([notification.name isEqualToString:kPNClientMessageSendingDidFailNotification]) {

        state = PNMessageSendingError;
        shouldUnsubscribe = YES;
        processingData = (PNError *)notification.userInfo;
    }
    else {

        shouldUnsubscribe = [notification.name isEqualToString:kPNClientDidSendMessageNotification];
        if (shouldUnsubscribe) {

            state = PNMessageSent;
        }
        processingData = (PNMessage *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientMessageSendCompletion];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientMessageProcessingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(state, processingData);
        }
    }];


    if (shouldUnsubscribe) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientMessageSendCompletion];
    }
}

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {

    // Retrieve reference on message which was received
    PNMessage *message = (PNMessage *)notification.userInfo;


    // Retrieving list of observers
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedMessage];

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientMessageHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(message);
        }
    }];
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {

    // Retrieve reference on presence event which was received
    PNPresenceEvent *presenceEvent = (PNPresenceEvent *)notification.userInfo;


    // Retrieving list of observers
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedPresenceEvent];

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceEventHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(presenceEvent);
        }
    }];
}

- (void)handleClientMessageHistoryProcess:(NSNotification *)notification {

    // Retrieve reference on history object
    PNMessagesHistory *history = nil;
    PNChannel *channel = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveMessagesHistoryNotification]) {

        history = (PNMessagesHistory *)notification.userInfo;
        channel = history.channel;
    }
    else {

        error = (PNError *)notification.userInfo;
        channel = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedHistory];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientHistoryLoadHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(history.messages, channel, history.startDate, history.endDate, error);
        }
    }];


    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedHistory];
}

- (void)handleClientHereNowProcess:(NSNotification *)notification {

    // Retrieve reference on participants object
    PNHereNow *participants = nil;
    PNChannel *channel = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveParticipantsListNotification]) {

        participants = (PNHereNow *)notification.userInfo;
        channel = participants.channel;
    }
    else {

        error = (PNError *)notification.userInfo;
        channel = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedParticipantsList];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientParticipantsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(participants.participants, channel, error);
        }
    }];


    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedParticipantsList];
}

- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification {

    PNError *error = nil;
    NSNumber *timeToken = nil;
    if ([[notification name] isEqualToString:kPNClientDidReceiveTimeTokenNotification]) {

        timeToken = (NSNumber *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientTimeTokenReceivingComplete];
    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientTimeTokenReceivingCompleteBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(timeToken, error);
        }
    }];


    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientTimeTokenReceivingComplete];
}


#pragma mark - Misc methods

- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName {

    if ([self.observers valueForKey:eventName] == nil) {
        
        [self.observers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.observers valueForKey:eventName];
}

- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName {
    
    if ([self.oneTimeObservers valueForKey:eventName] == nil) {
        
        [self.oneTimeObservers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.oneTimeObservers valueForKey:eventName];
}

- (NSMutableArray *)observersForEvent:(NSString *)eventName {

    NSMutableArray *persistentObservers = [self persistentObserversForEvent:eventName];
    NSMutableArray *oneTimeEventObservers = [self oneTimeObserversForEvent:eventName];


    // Composing full observers list depending on whether at least
    // one object exist in retrieved arrays
    NSMutableArray *allObservers = [NSMutableArray array];
    if ([persistentObservers count] > 0) {

        [allObservers addObjectsFromArray:persistentObservers];
    }

    if ([oneTimeEventObservers count] > 0) {

        [allObservers addObjectsFromArray:oneTimeEventObservers];
    }


    return allObservers;
}

#pragma mark -


@end
