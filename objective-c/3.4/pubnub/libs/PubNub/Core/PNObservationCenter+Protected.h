//
//  PNObservationCenter+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNObservationCenter.h"
#import "PNStructures.h"


@interface PNObservationCenter (Protected)


#pragma mark - Instance methods

/**
 * Check whether observer is subscribed on PubNub state
 * change
 */
- (BOOL)isSubscribedOnClientStateChange:(id)observer;


#pragma mark - Client connection state observation

/**
 * Add/remove observer which would like to know when PubNub client
 * is connected/disconnected to/from PubNub services at specified
 * origin.
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientConnectionStateObserver:(id)observer
                            oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;
- (void)removeClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver;


#pragma mark - Channels subscribe/leave observers

/**
 * Observing for subscription on list of channels
 * (this action will be performed only once per subscription).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsSubscriptionObserverWithBlock:(PNClientChannelSubscriptionHandlerBlock)handleBlock;
- (void)removeClientAsSubscriptionObserver;

/**
 * Add/remove observer for unsubscribe completion from list
 * of channels (this action will be performed only
 * once per unsubscription request).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsUnsubscribeObserverWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handleBlock;
- (void)removeClientAsUnsubscribeObserver;


#pragma mark - Time token observation

/**
 * Add PubNub client as observer for time token receiving
 * event till first event will arrive
 */
- (void)addClientAsTimeTokenReceivingObserverWithCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;
- (void)removeClientAsTimeTokenReceivingObserver;


#pragma mark - Message sending observers

/**
 * Add/remove observers for message sending process (completion
 * or error).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsMessageProcessingObserverWithBlock:(PNClientMessageProcessingBlock)handleBlock;
- (void)removeClientAsMessageProcessingObserver;
- (void)addMessageProcessingObserver:(id)observer
                           withBlock:(PNClientMessageProcessingBlock)handleBlock
                        oneTimeEvent:(BOOL)isOneTimeEventObserver;
- (void)removeMessageProcessingObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver;


#pragma mark - History observers

/**
 * Add/remove observers for history messages download
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsHistoryDownloadObserverWithBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;
- (void)removeClientAsHistoryDownloadObserver;


#pragma mark - Participants observer

/**
 * Add/remove observer for participants list download
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsParticipantsListDownloadObserverWithBlock:(PNClientParticipantsHandlingBlock)handleBlock;
- (void)removeClientAsParticipantsListDownloadObserver;

#pragma mark -


@end
