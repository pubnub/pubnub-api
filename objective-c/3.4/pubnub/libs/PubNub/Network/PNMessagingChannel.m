//
//  PNMessagingChannel.m
//  pubnub
//
//  This channel instance is required for
//  messages exchange between client and
//  PubNub service:
//      - channels messages
//      - channels presence events
//      - leave
//
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNMessagingChannel.h"
#import "PNConnectionChannel+Protected.h"
#import "PNBaseRequest+Protected.h"
#import "PNChannel+Protected.h"
#import "PNMessage+Protected.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNResponseParser.h"
#import "PNRequestsQueue.h"
#import "PNResponse.h"
#import "PNLeaveRequest+Protected.h"


#pragma mark - Private interface methods

@interface PNMessagingChannel ()


#pragma mark - Properties

// Stores list of channels (including presence)
// on which this client is subscribed now
@property (nonatomic, strong) NSMutableSet *subscribedChannels;


#pragma mark - Instance methods

/**
 * Check whether response should be processed on
 * this communication channel or not
 */
- (BOOL)shouldHandleResponse:(PNResponse *)response;

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request;


#pragma mark - Channels management

/**
 * Same function as -unsubscribeFromChannelsWithPresenceEvent:
 * but also allow to specify whether leave was triggered by user
 * or not
 */
- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent
                                        byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Same function as -unsubscribeFromChannels:withPresenceEvent:
 * but also allow to specify whether leave was triggered by user
 * or not
 */
- (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
                  byUserRequest:(BOOL)isLeavingByUserRequest;


#pragma mark - Presence management

/**
 * Send leave event to all channels to which
 * client subscribed at this moment
 *
 * As soon as client will receive leave request
 * confirmation all messages from unsubscribed
 * channels will be ignored
 */
- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest;
- (void)leaveChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest;


#pragma mark - Handler methods

/**
 * Called every time when client complete
 * leave request processing
 */
- (void)handleClientDidLeaveChannels:(NSArray *)channels;

/**
 * Called every time when one of events occur on
 * channels:
 *     - initial subscribe
 *     - message
 *     - presence event
 */
- (void)handleEventOnChannels:(NSArray *)channels withResponse:(PNResponse *)response;


#pragma mark - Misc methods

/**
 * Retrieve full list of channels on which channel should subscribe
 * including presence observing channels
 */
- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList;

/**
 * Retrieve list of channels which is cleared from presence observing
 * instances
 */
- (NSArray *)channelsWithOutPresenceFromList:(NSArray *)channelsList;


@end


#pragma mark Public interface methods

@implementation PNMessagingChannel


#pragma mark - Class methods

+ (PNMessagingChannel *)messageChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate {

    return [super connectionChannelWithType:PNConnectionChannelMessaging andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if((self = [super initWithType:PNConnectionChannelMessaging andDelegate:delegate])) {

        self.subscribedChannels = [NSMutableSet set];
    }


    return self;
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {

    return ([response.callbackMethod hasPrefix:PNServiceResponseCallbacks.subscriptionCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.sendMessageCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.leaveChannelCallback]);
}

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    // Check whether 'Leave' request has been processed or not
    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        // Process leave request process completion
        [self handleClientDidLeaveChannels:[(PNLeaveRequest *)request channels]];

        // Remove request from queue to unblock it (subscribe events and message post
        // requests was blocked)
        [self destroyRequest:request];
    }
    // Check whether 'Subscription'/'Presence'/'Events' request has been processed or not
    else if([request isKindOfClass:[PNSubscribeRequest class]]) {

        // Process subscription on channels
        [self handleEventOnChannels:[(PNSubscribeRequest *)request channels] withResponse:response];
    }
    // Check whether request was sent for message posting
    else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message post request will be sent now
        [self.messagingDelegate messagingChannel:self didSendMessage:((PNMessagePostRequest *)request).message];
    }
}

#pragma mark - Connection management

- (void)disconnectWithReset:(BOOL)shouldResetCommunicationChannel {
    
    // Forward to the super class
    [super disconnect];
    
    
    // Check whether communication channel should reset state or not
    if(shouldResetCommunicationChannel) {
        
        // Clean up channels stack
        [self.subscribedChannels removeAllObjects];
        [self purgeObservedRequestsPool];
        [self clearScheduledRequestsQueue];
    }
}

#pragma mark - Presence management

- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest {
    
    // Check whether there some channels which
    // user can leave
    if([self.subscribedChannels count] > 0) {

        // Reset last update time token for channels in list
        [self.subscribedChannels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        
        // Schedule request to be processed as soon as
        // queue will be processed
        [self scheduleRequest:[PNLeaveRequest leaveRequestForChannels:[self.subscribedChannels allObjects]
                                                        byUserRequest:isLeavingByUserRequest]
      shouldObserveProcessing:YES];
    }
}

- (void)leaveChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {

    // Check whether specified channels set contains channels
    // on which client not subscribed
    NSSet *channelsSet = [self channelsWithPresenceFromList:channels];
    if (![self.subscribedChannels intersectsSet:channelsSet]) {

        NSMutableSet *filteredChannels = [self.subscribedChannels mutableCopy];
        [filteredChannels intersectSet:channelsSet];
        channelsSet = filteredChannels;
    }

    // Retrieve set of channels (including presence observers) from
    // which client should unsubscribe
    NSSet *channelsForUnsubscribe = [self channelsWithPresenceFromList:[channelsSet allObjects]];
    if([channelsForUnsubscribe count] > 0) {

        // Reset last update time token for channels in list
        [channels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];


        // Schedule request to be processed as soon as
        // queue will be processed
        [self scheduleRequest:[PNLeaveRequest leaveRequestForChannels:[channelsForUnsubscribe allObjects]
                                                        byUserRequest:isLeavingByUserRequest]
      shouldObserveProcessing:YES];
    }
}


#pragma mark - Channels management

- (BOOL)isSubscribedForChannel:(PNChannel *)channel {
    
    return [self.subscribedChannels containsObject:channel];
}

- (void)resubscribe {

    // Ensure that client connected to at least one channel
    if ([self.subscribedChannels count] > 0) {

        // Unsubscribe from all channels with 'leave' presence
        // event generation
        NSArray *oldChannels = [self unsubscribeFromChannelsWithPresenceEvent:YES];

        [self scheduleRequest:[PNSubscribeRequest subscribeRequestForChannels:oldChannels]
      shouldObserveProcessing:YES];
    }
}

- (void)updateSubscription {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" UPDATE CHANNELS SUBSCRIPTION");

    // Ensure that client connected to at least one channel
    if ([self.subscribedChannels count] > 0) {

        [self scheduleRequest:[PNSubscribeRequest subscribeRequestForChannels:[self.subscribedChannels allObjects]]
      shouldObserveProcessing:NO];
    }
}

- (void)subscribeOnChannels:(NSArray *)channels {

    [self subscribeOnChannels:channels withPresenceEvent:YES];
}

- (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    // Checking whether client already subscribed on one of
    // channels from set or not
    NSMutableSet *channelsSet = [[self channelsWithPresenceFromList:channels] mutableCopy];
    if ([self.subscribedChannels intersectsSet:channelsSet]) {

        NSMutableSet *filteredChannels = [self.subscribedChannels mutableCopy];
        [filteredChannels intersectSet:channelsSet];
        [channelsSet minusSet:filteredChannels];
    }


    // In case if client currently connected to
    // PubNub services, we should send leave event
    NSMutableArray *subscriptionChannels = [[self unsubscribeFromChannelsWithPresenceEvent:withPresenceEvent
                                                                             byUserRequest:NO] mutableCopy];

    // Append channels on which client should subscribe
    [subscriptionChannels addObjectsFromArray:[channelsSet allObjects]];

    // Checking whether presence event should fire on subscription or not
    if (withPresenceEvent) {

        // Reset last update time token for channels in list
        [subscriptionChannels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
    }


    [self scheduleRequest:[PNSubscribeRequest subscribeRequestForChannels:subscriptionChannels]
  shouldObserveProcessing:YES];
}

- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent {

    return [self unsubscribeFromChannelsWithPresenceEvent:withPresenceEvent byUserRequest:YES];
}

- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent
                                        byUserRequest:(BOOL)isLeavingByUserRequest {

    NSArray *subscribedChannels = [self.subscribedChannels allObjects];

    // Check whether should generate 'leave' presence event
    // or not
    if (withPresenceEvent) {

        [self leaveSubscribedChannelsByUserRequest:isLeavingByUserRequest];
    }
    else {

        // Clean up list of subscribed channels so this communication
        // channel will ignore further messages from those channels if
        // they will arrive
        [self.subscribedChannels removeAllObjects];

        // Notify delegate that client leaved set of channels
        [self handleClientDidLeaveChannels:subscribedChannels];
    }


    return subscribedChannels;
}

- (void)unsubscribeFromChannels:(NSArray *)channels {

    [self unsubscribeFromChannels:channels withPresenceEvent:YES];
}

- (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent byUserRequest:YES];
}

- (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
                  byUserRequest:(BOOL)isLeavingByUserRequest {

    // Retrieve list of channels which will left after unsubscription
    NSMutableSet *currentlySubscribedChannels = [self.subscribedChannels mutableCopy];
    [currentlySubscribedChannels minusSet:[self channelsWithPresenceFromList:channels]];


    if (withPresenceEvent) {

        [self leaveChannels:channels byUserRequest:isLeavingByUserRequest];

        // Reset last update time token for channels in list
        [currentlySubscribedChannels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
    }
    else {

        // Remove all channels from subscribed channels set
        // (all further messages from those channels will
        // be ignored)
        [self.subscribedChannels removeAllObjects];


        // Notify delegate that client leaved set of channels
        [self handleClientDidLeaveChannels:channels];
    }


    // Resubscribe on rest of channels which is left after unsubscribe
    [self scheduleRequest:[PNSubscribeRequest subscribeRequestForChannels:[currentlySubscribedChannels allObjects]]
  shouldObserveProcessing:YES];
}


#pragma mark - Presence observation management

- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {
    
    PNChannelPresence *presenceObserver = [channel presenceObserver];
    
    
    return presenceObserver != nil && [self.subscribedChannels containsObject:presenceObserver];;
}

- (void)enablePresenceObservationForChannels:(NSArray *)channels {

    [self subscribeOnChannels:[channels valueForKey:@"presenceObserver"] withPresenceEvent:NO];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels {

    [self unsubscribeFromChannels:[channels valueForKey:@"presenceObserver"] withPresenceEvent:NO];
}


#pragma mark - Messages processing methods

- (PNMessage *)sendMessage:(NSString *)message toChannel:(PNChannel *)channel {

    // Create message instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithText:message forChannel:channel error:&error];

    // Checking whether
    if (messageObject) {

        // Schedule message sending request
        [self scheduleRequest:[PNMessagePostRequest postMessageRequestWithMessage:messageObject]
      shouldObserveProcessing:YES];
    }
    else {

        // Notify delegate about message sending error
        [self.messagingDelegate messagingChannel:self didFailMessageSend:messageObject withError:error];
    }


    return messageObject;
}

- (void)sendMessage:(PNMessage *)message {

    if (message) {

        // Schedule message sending request
        [self scheduleRequest:[PNMessagePostRequest postMessageRequestWithMessage:message]
      shouldObserveProcessing:YES];
    }
}


#pragma mark - Handler methods

- (void)handleClientDidLeaveChannels:(NSArray *)channels {

    // Forward unsubscribe request to PubNub client so he can
    // distribute further notifications
    [self.messagingDelegate messagingChannel:self didUnsibscribeFromChannels:channels];
}

- (void)handleEventOnChannels:(NSArray *)channels withResponse:(PNResponse *)response {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" SUBSCRIBE REQUEST RESPONSE: %@", response);

    PNResponseParser *parser = [PNResponseParser parserForResponse:response];

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PARSED DATA: %@", parser);

    // Check whether there is no error in response
    if (parser.error == nil) {

        // Check whether events arrived from PubNub service
        // (messages, presence)
        if ([parser.events count] > 0) {

            // TODO: NOTIFY DELEGATE ON MESSAGES AND PRESENCE EVENTS
        }
        else {

            NSUInteger oldChannelsCount = [self.subscribedChannels count];

            // Append channels to the list of channels on which client
            // is subscribed at this moment
            [self.subscribedChannels addObjectsFromArray:channels];

            // Checking whether number of channels on which client subscribed
            // is changed or not (if changed, this means that we should notify
            // delegate and observer that client subscribed on new channels)
            if (oldChannelsCount != [self.subscribedChannels count]) {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" NOTIFY ON SUBSCRIPTION");

                // Notify delegate that message channel subscribed on specified
                // set of channels
                [self.messagingDelegate messagingChannel:self didSubscribeOnChannels:channels];
            }
        }

        // Retrieve event time token
        NSString *timeToken = parser.updateTimeToken?parser.updateTimeToken:@"0";

        // Update channels state update time token
        [self.subscribedChannels makeObjectsPerformSelector:@selector(setUpdateTimeToken:) withObject:timeToken];


        // Subscribe to the channels with new update time token
        [self updateSubscription];
    }
    else {

        // TODO: NOTIFY DELEGATE THAT SUBSCRIBE ERROR OCCURRED
    }
}


#pragma mark - Misc methods

- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList {
    
    NSMutableSet *fullChannelsList = [NSMutableSet setWithCapacity:[channelsList count]];
    [channelsList enumerateObjectsUsingBlock:^(PNChannel *channel,
                                               NSUInteger channelIdx,
                                               BOOL *channelEnumeratorStop) {

        [fullChannelsList addObject:channel];
        PNChannelPresence *presenceObserver = [channel presenceObserver];
        if (presenceObserver) {

            [fullChannelsList addObject:presenceObserver];
        }
    }];
    
    
    return fullChannelsList;
}

- (NSArray *)channelsWithOutPresenceFromList:(NSArray *)channelsList {

    // Compose filtering predicate to retrieve list of channels
    // which are not presence observing channels
    NSString *filterFormat = @"shouldObservePresence = %@";
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterFormat, @NO];


    return [channelsList filteredArrayUsingPredicate:filterPredicate];
}


#pragma mark - Connection delegate methods

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {
    
    if([self shouldHandleResponse:response]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" RECIEVED RESPONSE: %@", response);

        // Retrieve reference on observer request
        PNBaseRequest *request = [self observedRequestWithIdentifier:response.requestIdentifier];
        [self destroyRequest:request];

        [self processResponse:response forRequest:request];


        // Asking to schedule next request
        [self scheduleNextRequest];
    }
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" WILL START REQUEST PROCESSING: %@ [BODY: %@]", request, request.resourcePath);

    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        // Check whether connection should be closed for resubscribe
        // or not
        if (((PNLeaveRequest *)request).shouldCloseConnection) {

            // Mark that we don't need to close connection after next time
            // this request will be scheduled for processing
            // (this will happen right after connection will be restored)
            ((PNLeaveRequest *)request).closeConnection = NO;

            // Reconnect communication channel
            [self reconnect];
        }
    }
    // Check whether request was sent for message posting
    else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message post request will be sent now
        [self.messagingDelegate messagingChannel:self willSendMessage:((PNMessagePostRequest *)request).message];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID SEND REQUEST: %@ [BODY: %@]", request, request.resourcePath);


    // If we are not waiting for request completion, inform delegate
    // immediately
    if (![self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Check whether this is 'Subscribe' request or not
        // (there probably no situation when this situation will take place)
        if ([request isKindOfClass:[PNSubscribeRequest class]]) {

            // Notify delegate about that client subscribed on required channels
            [self.messagingDelegate messagingChannel:self
                              didSubscribeOnChannels:((PNSubscribeRequest *)request).channels];
        }
        // Check whether this is 'Leave' request or not
        // (there probably no situation when this situation will take place)
        else if ([request isKindOfClass:[PNLeaveRequest class]]) {

            // Notify delegate about that client leaved set of channels
            [self.messagingDelegate messagingChannel:self
                          didUnsibscribeFromChannels:((PNLeaveRequest *)request).channels];
        }
        // Check whether this is 'Post message' request or not
        else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            // Notify delegate about that message post request has been sent
            [self.messagingDelegate messagingChannel:self didSendMessage:((PNMessagePostRequest *)request).message];
        }
    }


    [self scheduleNextRequest];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Forward to the super class
    [super requestsQueue:queue didFailRequestSend:request withError:error];


    PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" DID FAIL TO SEND REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        // Check whether request can be rescheduled or not
        if (![request canRetry]) {

            // Removing failed request from queue
            [self destroyRequest:request];


            PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" REQUEST PROCESSING FAILED (REMOVED): %@",
                  request);

            // Check whether this is 'Subscribe' request or not
            if ([request isKindOfClass:[PNSubscribeRequest class]]) {

                // Notify delegate about that client failed to subscribe on channels
                [self.messagingDelegate messagingChannel:self
                              didFailSubscribeOnChannels:((PNSubscribeRequest *)request).channels
                                               withError:error];
            }
            // Check whether this is 'Leave' request or not
            else if ([request isKindOfClass:[PNLeaveRequest class]]) {

                // Notify delegate about that client failed to leave set of channels
                [self.messagingDelegate messagingChannel:self
                            didFailUnsubscribeOnChannels:((PNLeaveRequest *)request).channels
                                               withError:error];
            }
            // Check whether this is 'Post message' request or not
            else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

                // Notify delegate about that message can't be send
                [self.messagingDelegate messagingChannel:self
                                      didFailMessageSend:((PNMessagePostRequest *)request).message
                                               withError:error];
            }
        }


        [self scheduleNextRequest];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didCancelRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID CANCEL REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);
}

#pragma mark -


@end
