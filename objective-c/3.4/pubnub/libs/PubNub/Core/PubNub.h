//
//  PubNub.h
//  pubnub
//
//  This is base and main class which is
//  responsible for communication with
//  PubNub services and handle all events
//  and notifications.
//
//
//  Created by Sergey Mamontov.
//
//

#import <Foundation/Foundation.h>
#import "PNStructures.h"
#import "PNDelegate.h"


#pragma mark Class forward

@class PNConfiguration, PNChannel, PNMessage;


@interface PubNub : NSObject


#pragma mark - Class methods

/**
 * Retrieve reference on shared PubNub client instance
 */
+ (PubNub *)sharedInstance;


#pragma mark - Client connection management methods

/**
 * Launch configured PubNub client (this will cause initial
 * connection which will retrieve time token from backend
 * and open two connections/sockets which will be used for
 * communication with PubNub services).
 */
+ (void)connect;

/**
 * Perform same action as +connect but in addition provides
 * handling blocks
 */
+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure;

/**
 * Will disconnect from all channels w/o sending leave
 * event and terminate all socket connection which was
 * established to PubNub services.
 * All scheduled messages will be discarded.
 */
+ (void)disconnect;


#pragma mark - Client configuration

/**
 * Perform initial configuration or update existing one
 * If PubNub was previously configured, it will perform
 * "hard reset".
 * "hard reset" - is action when all connection will be 
 * dropped w/o notify to the server. All scheduled
 * messages will be discarded (try to avoid runtime client
 * re-configuration)
 */
+ (void)setConfiguration:(PNConfiguration *)configuration;
+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;

/**
 * Specify PubNub client delegate for event callbacks
 */
+ (void)setDelegate:(id<PNDelegate>)delegate;


#pragma mark - Client identification

/**
 * Update current PubNub client identifier (unique user identifier
 * or basically username/nickname)
 * If PubNub was previously configured, it will perform
 * "soft reset".
 * If 'nil' is passed, than random unique identifier will
 * be generated.
 * "soft reset" - is action when before connection drop 
 *                client will send "leave" messages to
 *                the server which will allow to process
 *                presence correctly.
 */
+ (void)setClientIdentifier:(NSString *)identifier;

/**
 * Retrieve current PubNub client identifier which will/used to
 * establish connection with PubNub services
 */
+ (NSString *)clientIdentifier;


#pragma mark - Channels subscription management

/**
 * Retrieve list of channels on which client is subscribed
 */
+ (NSArray *)subscribedChannels;

/**
 * Check whether client subscribed for specified channel or not
 */
+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel;

/**
 * Will subscribe client for another one channel.
 * This request will add provided channel to the
 * list of channels on which client already subscribed.
 * By default this method will trigger presence event
 * by sending leave to channels to which client already
 * connected and then re-subscribe generating 'join' event.
 *
 * Only last call of this method will call completion block.
 * If you need to track subscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)subscribeOnChannel:(PNChannel *)channel;
+ (void) subscribeOnChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 * Will subscribe client for another one channel.
 * This request will add provided channel to the
 * list of channels on which client already subscribed.
 *
 * If 'withPresenceEvent' is set to YES, than 'join' presence
 * event will be triggered right after connected channels will
 * trigger 'leave' presence event.
 *
 * Only last call of this method will call completion block.
 * If you need to track subscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;
+ (void)subscribeOnChannel:(PNChannel *)channel
         withPresenceEvent:(BOOL)withPresenceEvent
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 * Will subscribe client for another channels set.
 * This request will add provided channels set to the
 * list of channels on which client already subscribed.
 * By default this method will trigger presence event
 * by sending leave to channels to which client already
 * connected and then re-subscribe generating 'join' event.
 *
 * Only last call of this method will call completion block.
 * If you need to track subscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)subscribeOnChannels:(NSArray *)channels;
+ (void)subscribeOnChannels:(NSArray *)channels
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 * Will subscribe client for another one channel.
 * This request will add provided channel to the
 * list of channels on which client already subscribed.
 *
 * If 'withPresenceEvent' is set to YES, than 'join' presence
 * event will be triggered right after connected channels will
 * trigger 'leave' presence event.
 *
 * Only last call of this method will call completion block.
 * If you need to track subscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;
+ (void)subscribeOnChannels:(NSArray *)channels
          withPresenceEvent:(BOOL)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 * Will unsubscribe client from specified channel.
 * Specified channel will be removed from the list
 * of subscribed channels.
 *
 * If there is no connection, than all channels will
 * be leaved w/o sending "leave" message.
 *
 * Only last call of this method will call completion block.
 * If you need to track unsubscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel;
+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

/**
 * Will unsubscribe client from specified channel.
 * Specified channel will be removed from the list
 * of subscribed channels.
 *
 * If there is no connection, than all channels will
 * be leaved w/o sending "leave" message.
 *
 * If 'withPresenceEvent' is set to YES, than 'leave' presence
 * event will be triggered.
 *
 * Only last call of this method will call completion block.
 * If you need to track unsubscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;
+ (void)unsubscribeFromChannel:(PNChannel *)channel
             withPresenceEvent:(BOOL)withPresenceEvent
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

/**
 * Will unsubscribe client from set of channels.
 * Specified set of channels will be removed from
 * the list of subscribed channels.
 * Leave event will be sent on provided list of
 * channels.
 * If there is no connection, than all channels will
 * be leaved w/o sending 'leave' message.
 *
 * Only last call of this method will call completion block.
 * If you need to track unsubscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels;
+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

/**
 * Will unsubscribe client from set of channels.
 * Specified set of channels will be removed from
 * the list of subscribed channels.
 *
 * If there is no connection, than all channels will
 * be leaved w/o sending "leave" message.
 *
 * If 'withPresenceEvent' is set to YES, than 'leave' presence
 * event will be triggered.
 *
 * Only last call of this method will call completion block.
 * If you need to track unsubscribe process from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;
+ (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;


#pragma mark - Presence management

/**
 * Checking whether client added presence observation on particular
 * channel or not
 */
+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;

/**
 * Enable presence observation for specific channel
 */
+ (void)enablePresenceObservationForChannel:(PNChannel *)channel;

/**
 * Enable presence observation for list of channels
 */
+ (void)enablePresenceObservationForChannels:(NSArray *)channels;

/**
 * Disable presence observation for specific channel
 */
+ (void)disablePresenceObservationForChannel:(PNChannel *)channel;

/**
 * Disable presence observation for list of channels
 */
+ (void)disablePresenceObservationForChannels:(NSArray *)channels;


#pragma mark - Time token

/**
 * Send asynchronous time token request to PubNub
 * services.
 * Response will retrieve all who subscribed for
 * time token retrieval via observer center or
 * notifications
 */
+ (void)requestServerTimeToken;

/**
 * Same as +requestServerTimeToken but allow to specify
 * completion block which will be called when time token
 * will be fetched from remote PubNub services.
 * If more than 1 observer want to know about time token
 * arrival, than they can use PNObservationCenter and
 * subscribe for event with block or listen notifications.
 *
 * Only last call of this method will call completion block.
 * If you need to track time token retrieval from many places,
 * use PNObservationCenter methods for this purpose.
 */
+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;


#pragma mark - Messages processing methods

/**
 * Asynchronously send message to the PubNub service.
 * All messages which sent to the PubNub service are
 * sent via FIFO queue which guarantee that they all
 * will be sent in same order as thet was scheduled.
 * Delegate as well as observers will receive
 * notification when message will/did sent
 *
 * @return PNMessage instance which will represent message
 *         which is sent for processing
 */
+ (PNMessage *)sendMessage:(NSString *)message toChannel:(PNChannel *)channel;

/**
 * Same as +sendMessage:toChannel: but allow to specify
 * completion block which will be called when message will
 * be sent or in case of error.
 *
 * Only last call of this method will call completion block.
 * If you need to track message sending from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (PNMessage *)sendMessage:(NSString *)message
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 * Asynchronously send configured message object
 * to PubNub service.
 */
+ (void)sendMessage:(PNMessage *)message;

/**
 * Same as +sendMessage: but allow to specify
 * completion block which will be called when message will
 * be sent or in case of error.
 *
 * Only last call of this method will call completion block.
 * If you need to track message sending from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success;


#pragma mark - History methods

/**
 * Fetch all history for specified channel
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel;

/**
 * Same as +requestFullHistoryForChannel: but allow to specify
 * completion block which will be called when messages history will
 * be received.
 *
 * Only last call of this method will call completion block.
 * If you need to track history loading events from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 * Fetch history for specified channel in defined
 * time frame
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(NSDate *)startDate to:(NSDate *)endDate;

/**
 * Same as +requestHistoryForChannel:from:to: but allow to specify
 * completion block which will be called when messages history will
 * be received.
 *
 * Only last call of this method will call completion block.
 * If you need to track history loading events from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 * Fetch history for specified channel in defined
 * time frame with specified limits
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit;

/**
 * Same as +requestHistoryForChannel:from:to:limit: but allow to specify
 * completion block which will be called when messages history will
 * be received.
 *
 * Only last call of this method will call completion block.
 * If you need to track history loading events from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 * Fetch history for specified channel in defined
 * time frame, limit and whether response should
 * be inverted or not
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 * Same as +requestHistoryForChannel:from:to:limit:reverseHistory:
 * but allow to specify completion block which will be called when
 * messages history will be received.
 *
 * Only last call of this method will call completion block.
 * If you need to track history loading events from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(NSDate *)startDate
                              to:(NSDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;


#pragma mark - Participant methods

/**
 * Request list of participants for specified channel
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel;

/**
 * Same as +requestParticipantsListForChannel: but allow to
 * specify completion block which will be called when
 * list of participants will be returned by PubNub service
 *
 * Only last call of this method will call completion block.
 * If you need to track history loading events from many places, use
 * PNObservationCenter methods for this purpose.
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;


#pragma mark - Instance methods

/**
 * Check whether PubNub client connected to origin
 * and ready to work or not
 */
- (BOOL)isConnected;

#pragma mark -


@end
