# PubNub 3.4  
---  

PubNub is an iOS ARC support Objective-C library wrapper for the Pubnub realtime messaging service [PubNub.com](http://www.pubnub.com/).  
PubNub client uses sockets to communicate with remote server. Each request on server is asynchronous and handled by callback blocks (also blocks from observation centre), delegate methods and notifications.  
Detailed information on method/constant/notification can be found in corresponding header file.  
  
  
## Adding PubNub in your project  

1. Add JSONKit supported files in your project (they are stored in pubnub/libs/JSONKit)  
2. Add PubNub library folder (whole folder) in your project (library folder is stored in pubnub/libs)  
3. Add PNImports in your project precompile header (.pch)  

        #import "PNImports.h"

4. Thats it, now you can start using PubNub library with your application.  

## Client configuration

PubNub client can be used right __"out-of-box"__ to check features right away without any additional settings.  Before you will go production you will have to update default settings.  
Client is configured with instance of [__PNConfiguration__](3.4/pubnub/libs/PubNub/Data/PNConfiguration.h) class. All default configuration is stored in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) under appropriate keys.  
Data from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) is used when some of configuration value wasn't configured during initialisation.  
You can use few class methods to intialise and update instance properties:  

1. Retrieve reference on default client configuration (all values taken from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
  
       + (PNConfiguration *)defaultConfiguration;  
  
2. Retrieve reference on configuration instance created with provided set of methods:  
  
       + (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey  
                                           subscribeKey:(NSString *)subscribeKey  
                                              secretKey:(NSString *)secretKey;  
       + (PNConfiguration *)configurationForOrigin:(NSString *)originHostName  
                                        publishKey:(NSString *)publishKey  
		                              subscribeKey:(NSString *)subscribeKey  
		                                 secretKey:(NSString *)secretKey;  
       + (PNConfiguration *)configurationForOrigin:(NSString *)originHostName  
		                                publishKey:(NSString *)publishKey  
		                              subscribeKey:(NSString *)subscribeKey  
		                                 secretKey:(NSString *)secretKey  
		                                 cipherKey:(NSString *)cipherKey;  

  
3. Update configuration instance using next set of parameters:  

    1.  Timeout after which library will report non subscription request (here now, leave, message history, message post, time token) execution failure.  
  
           nonSubscriptionRequestTimeout  
        __Default:__ 15 seconds (_kPNNonSubscriptionRequestTimeout_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
        
    2.  Timeout after which library will report subscription request (subscribe on channel(s)) execution failure. For default configuration creation way this value is stored inside [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) under __kPNSubscriptionRequestTimeout__ key.  
      
           subscriptionRequestTimeout  
        __Default:__ 10 seconds (_kPNSubscriptionRequestTimeout_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    3.  Whether PubNub client should restore connection (if was connected) after network connection has been restored or not.  
      
           (getter = shouldAutoReconnectClient) autoReconnectClient  
        __Default:__ YES (_kPNShouldResubscribeOnConnectionRestore_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    3.  Whether PubNub client should restore subscription on previously subscribed channels or should subscribe on the with __"0"__ time token.  
      
           (getter = shouldResubscribeOnConnectionRestore) resubscribeOnConnectionRestore  
        __Default:__ YES (_kPNShouldResubscribeOnConnectionRestore_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    4.  Whether PubNub client should establish connection to remote origin using SSL or not.  
      
           (getter = shouldUseSecureConnection) useSecureConnection  
        __Default:__ YES (_kPNSecureConnectionRequired__ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    5.  Whether PubNub client is able to reduce security level (SSL settings adjustment) if server at this moment poses issue with SSL certificate and client because of settings won't allow connection to insecure host.  
      
           (getter = shouldReduceSecurityLevelOnError) reduceSecurityLevelOnError  
        __Default:__ YES (_kPNShouldReduceSecurityLevelOnError_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    6.  Whether PubNub client is able to disable SSL requirement (secure connection) in case if remote origin closed connection because of issue caused by SSL connection configuration.  
      
           (getter = canIgnoreSecureConnectionRequirement) ignoreSecureConnectionRequirement  
        __Default:__ YES (_kPNCanIgnoreSecureConnectionRequirement_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
  
Also if you are using `+defaultConfiguration` method to create configuration instance, than you will need to update:  _kPNPublishKey_, _kPNSubscriptionKey_ and _kPNOriginHost_ keys in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h).  
  
PubNub client configuration as fast as this record:  
  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  
        
After this record, your PubNub client is configured with default values taken from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) and ready to be connected right now.  
  
There are few methods which allow to adjust client configuration:  
  
    + (void)setConfiguration:(PNConfiguration *)configuration;  
    + (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;  
    + (void)setDelegate:(id<PNDelegate>)delegate;  
    + (void)setClientIdentifier:(NSString *)identifier;  
    
Two methods which update client configuration may require __hard state reset__ if client already connected. What does it mean "__hard state reset__"? It means that client will close connection without sending `leave` request on subscribed channels and reconnect using new configuration.  
Client identifier change may require __soft state reset__ if client already connected. What does it mean "__soft state reset__"? It means that client will send `leave` request on subscribed channels and resubscribe with new identifier. All channels which can accept presence events will show chain of event:  
  
    > user 'xxxx' leaved  
    > user 'yyyy' joined 
    
Also you can pull out some information about client state and some of the properties with next methods:  
    
    + (PubNub *)sharedInstance;  
    + (NSString *)clientIdentifier;  
    + (NSArray *)subscribedChannels;  
    
    + (BOOL)isSubscribedOnChannel:(PNChannel *)channel;  
    + (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;  
    
    - (BOOL)isConnected;  

## PubNub client methods  

### Connect/disconnect to/from remote PubNub service  

You can use callback-less connection methods `+connect` to establish connection to remote PubNub service or method with state callback blocks `+connectWithSuccessBlock:errorBlock:`.  

For example you can use provided method in the form which you like the most:  
    
    // Configure client (we will use client generated identifier)  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  
    
    [PubNub connect];  

or
    
    // Configure client  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub setClientIdentifier:@"test_user"];  
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {  
    
                             // Do something after client connected  
                         } 
                         errorBlock:^(PNError *error) {
                                              
                             // Handle error which occurred while client tried to  
                             // establish connection with remote service
                         }];
                                          
Disconnection as simple as call `[PubNub disconnect]` and client will close connection and clean up all caches (client cache some data for performance reason).  

### Channels representation  

Client uses [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance instead of string literals to identify channel.  
So when you need to send message to the channel, than you have to specify corresponding [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance in message sending methods.  

[__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) interface provide few methods for channels instantiation (inside it will use cached data, so instance in fact will be created only if they wasn't created before):  
    
    + (NSArray *)channelsWithNames:(NSArray *)channelsName;  
    
    + (id)channelWithName:(NSString *)channelName;  
    + (id)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence;  

You can use first method if you want to receive set of [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instances from list of channel identifiers.  
`observePresence` property is used to mark whether client should observe presence events on specified channel or not.  
As for name you can use any characters you want except ',' because it is reserved by PubNub service.  

Also [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance can provide you with usable information about itself (properties):  
    
* `name` - channel name  
* `updateTimeToken` - time token when last update occurred on this channel  
* `presenceUpdateDate` - date when last presence update arrived to this channel  
* `participantsCount` - number of participants in this channel (is subscribed on presence event or manyally pulled out presence information)  
* `participants` - list of participant UUIDs  
  
Lets say we want to receive reference on list of channel instances:  
  
    NSArray *channels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev"]];  

### Subscribe/unsubscribe to/from channels

There is set of methods which allow you to subscribe on desired channel(s):  
    
    + (void)subscribeOnChannel:(PNChannel *)channel;  
    + (void) subscribeOnChannel:(PNChannel *)channel  
    withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
    
    + (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;  
    + (void)subscribeOnChannel:(PNChannel *)channel  
             withPresenceEvent:(BOOL)withPresenceEvent  
    andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
    
    + (void)subscribeOnChannels:(NSArray *)channels;  
    + (void)subscribeOnChannels:(NSArray *)channels  
    withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
    
    + (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;  
    + (void)subscribeOnChannels:(NSArray *)channels  
              withPresenceEvent:(BOOL)withPresenceEvent  
     andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  

As you can see, each subscription method has designated methods (one to add presence observing flag and another add handling block).  
If `withPresenceEvent` is set to `YES` than before subscribe on new channel(s) library will send `leave` request to already subscribed channels and `join` presence event will be triggers on all channels after client will subscribe on new one.  

Lets see how we can use some of this methods to subscribe on channel(s):  
    
    // Simply subscribe on channel  
    [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];  

    // Subscribe on set of channels with subscription state handling block (won't observe presence)  
    [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev"]]  
    withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {  
        
        switch(state) {  
        
            case PNSubscriptionProcessNotSubscribedState:  
            
                // Check whether 'subscriptionError' instance is nil or not (if not, handle error)  
                break;  
            case PNSubscriptionProcessSubscribedState:  
            
                // Do something after subscription completed  
                break;  
            case PNSubscriptionProcessWillRestoreState:  
            
                // Library is about to restore subscription on channels after connection went down and restored  
                break;  
            case PNSubscriptionProcessRestoredState:  
            
                // Handle event that client completed resubscription  
                break;  
        }  
    }];  

There is same count of methods (as for subscription) to unsubscribe from channels(s):  
    
    + (void)unsubscribeFromChannel:(PNChannel *)channel;  
    + (void)unsubscribeFromChannel:(PNChannel *)channel  
       withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
       
    + (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;  
    + (void)unsubscribeFromChannel:(PNChannel *)channel  
                 withPresenceEvent:(BOOL)withPresenceEvent  
        andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
        
    + (void)unsubscribeFromChannels:(NSArray *)channels;  
	+ (void)unsubscribeFromChannels:(NSArray *)channels  
	    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
	    
	+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;  
	+ (void)unsubscribeFromChannels:(NSArray *)channels  
	              withPresenceEvent:(BOOL)withPresenceEvent  
	     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
	     
Same as for subscription there is a set of designated methods (with extended set of parameters) which allow to perform unsubscribe request with less code if you like default parameters.  
In unsubscribe set of methods `withPresenceEvent` parameter set to `YES` will mean that client should send `leave` message to channels from which we unsubscribe.  

Lets see how we can use some of this methods to unsubscribe from channel(s):  
    
    // Unsubscribe from set of channels and notify everyone that we are leaved  
    [PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev/networking", @"andoirddev", @"wpdev", @"ubuntudev"]]  
                 withPresenceEvent:YES   
        andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {  
        
            // Check whether "unsubscribeError" is nil or not (if not, than handle error)  
        }];  

### Channels presence observing

If your account is suitable for presence event handling, than you can use this feature to receive updates about channel presence changes: join, leave, timeout.  

To manage presence observing you can use set of methods with straightforward names:  
    
    + (void)enablePresenceObservationForChannel:(PNChannel *)channel;  
    + (void)enablePresenceObservationForChannels:(NSArray *)channels;  
    + (void)disablePresenceObservationForChannel:(PNChannel *)channel;  
    + (void)disablePresenceObservationForChannels:(NSArray *)channels;  

### Time token

You can always retrieve from PubNub service current time token (GMT+0). It is usable to track real time and date (not based on local device time) and escape from 0-day vulnerability on client side.  

You can use set of methods to request time token:  
  
    + (void)requestServerTimeToken;  
    + (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;  
    
Usage is very simple:  

    [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {  
        
        if (error == nil) {  
        
            // Use received time token as you whish  
        }  
        else {  
            
            // Handle time token retrival error  
        }  
    }];  

### Messaging

Messaging is the core PubNub functionality for which it was designed. User is able to send any messages to the channel and it will be distributed amont channel subscribers.  
Messages should be serialised into JSON string before sending it, in other case service will respond with error.  

Here is the set of methods which you can use to send messages to the channel:  
  
    + (PNMessage *)sendMessage:(NSString *)message toChannel:(PNChannel *)channel;   
    + (PNMessage *)sendMessage:(NSString *)message  
                 toChannel:(PNChannel *)channel  
       withCompletionBlock:(PNClientMessageProcessingBlock)success;  
       
    + (void)sendMessage:(PNMessage *)message;  
    + (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success;  

As you can see two first methods exchange your message sending request into [__PNMessage__](3.4/pubnub/libs/PubNub/Data/PNMessage.h) instance. You can save this instance elsewhere and in case of some kind of error or maybe because of your application functionality you can pass that object to last two methods and they will be sent (channel already specified inside of this object).  
  
    PNMessage *helloMessage = [PubNub sendMessage:@"\"Hello PubNub\""  
                                        toChannel:[PNChannel channelWithName:@"iosdev"]  
                              withCompletionBlock:^(PNMessageState messageSendingState, id data) {  
                                    
                                  switch (messageSendingState) {  
                                        
                                      case PNMessageSending:  
                                            
                                          // Handle message sending event (it means that message processing started and  
                                          // still in progress)  
                                          break;  
                                      case PNMessageSent:  
                                          
                                          // Handle message sent event  
                                          break;  
                                      case PNMessageSendingError:  
                                          
                                          // Retry message sending (but in real world should check error and hanle it)  
                                          [PubNub sendMessage:helloMessage];  
                                          break;  
                                  }  
                              }];  

### History

PubNub client allow you to pull out history for any particular channel. Channel feature should be enabled in your account and by default it will be stored for 24-72h.  

There is a set of designated methods to fetch history:  
  
    + (void)requestFullHistoryForChannel:(PNChannel *)channel;  
    + (void)requestFullHistoryForChannel:(PNChannel *)channel   
                     withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
                     
    + (void)requestHistoryForChannel:(PNChannel *)channel from:(NSDate *)startDate to:(NSDate *)endDate;  
    + (void)requestHistoryForChannel:(PNChannel *)channel  
                                from:(NSDate *)startDate  
                                  to:(NSDate *)endDate  
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
                 
	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(NSDate *)startDate  
	                              to:(NSDate *)endDate  
	                           limit:(NSUInteger)limit;  
	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(NSDate *)startDate  
	                              to:(NSDate *)endDate  
	                           limit:(NSUInteger)limit  
	             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  

	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(NSDate *)startDate  
	                              to:(NSDate *)endDate  
	                           limit:(NSUInteger)limit  
	                  reverseHistory:(BOOL)shouldReverseMessageHistory;  
	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(NSDate *)startDate  
	                              to:(NSDate *)endDate  
	                           limit:(NSUInteger)limit  
	                  reverseHistory:(BOOL)shouldReverseMessageHistory  
	             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
	             
There is a group of methods, in each group there is one for simple request (it's progress available via notifications and delegate callbacks) and second allow to handle right in place.  
Each new group adds more parameter to help specify time frame for history, whether should traverse from latests and specify limit of messages which will be returned at once.  
First two methods allow to receive full history for specified channel.  
  
This example allow to pull history for `iosdev` channel with specified time frame, last 34 messages will be returned.  
    
    NSDate *startDate;  
    NSDate *endDate;  
    int limit = 34;  
    [PubNub requestHistoryForChannel:[PNChannel channelWithName:@"iosdev"]  
                                from:startDate  
                                  to:endDate  
                               limit:limit  
                      reverseHistory:NO  
                 withCompletionBlock:^(NSArray *messages,  
                                       PNChannel *channel,  
                                       NSDate *startDate,  
                                       NSDate *endDate,  
                                       PNError *error) {  
                                       
                     if (error == nil) {  
                     
                         // Handle received messages history  
                     }  
                     else {  
                     
                         // Handle history fetch error  
                     }  
                 }];  

### Channel presence

PubNub client also allow to pull out list of channel participants.  
As always there is two methods: one notification based and one with block callback:  
  
    + (void)requestParticipantsListForChannel:(PNChannel *)channel;  
    + (void)requestParticipantsListForChannel:(PNChannel *)channel  
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;  
                      
Example:  
  
    [PubNub requestParticipantsListForChannel:[PNChannel channelWithName:@"iosdev"]  
                          withCompletionBlock:^(NSArray *udids,  
                                                PNChannel *channel,  
                                                PNError *error) {  
        if (error == nil) {  
        
            // Handle participants UDIDs retrival  
        }  
        else {  
            
            // Handle participants request error  
        }  
    }];  

## Error handling

In case of error client will generate instance of PNError which include error code (error codes is stored in PNErrorCodes.h) and additional information which is available via methods: `localizedDescription`, `localizedFailureReason`, `localizedRecoverySuggestion`.  
Also in some cases error object contains context instance with which error is occurred (value stored in `associatedObject`).  
  
  
## Event handling

PubNub client provide few methods to handle difference events:  

1. delegate callbacks  
2. block callback from used methods  
3. observation center ([__PNObservationCenter__](3.4/pubnub/libs/PubNub/Core/PNObservationCenter.h))  
4. notifications  

### Delegate callback methods  

At one time there can be only one PubNub client delegate. Delegate class should conform to [__PNDelegate__](pubnub/libs/PubNub/Misc/Protocols/PNDelegate.h) protocol to be able receive callbacks.  

Here is full set of callbacks which is available in current version:  
  
    - (void)pubnubClient:(PubNub *)client error:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin;  
    - (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin;  
    - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin;  
    - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error;  
    - (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error;  
    - (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken;  
    - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message;  
    - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error;  
    - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message;  
    - (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message;  
    - (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event;  
    
    - (void)    pubnubClient:(PubNub *)client  
    didReceiveMessageHistory:(NSArray *)messages  
                  forChannel:(PNChannel *)channel  
                startingFrom:(NSDate *)startDate  
                          to:(NSDate *)endDate;  
    - (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;  
    
    - (void)      pubnubClient:(PubNub *)client  
    didReceiveParticipantsLits:(NSArray *)participantsList  
                    forChannel:(PNChannel *)channel;  
	- (void)                     pubnubClient:(PubNub *)client  
	didFailParticipantsListDownloadForChannel:(PNChannel *)channel  
	                                withError:(PNError *)error;  
	                                
	- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;  
	- (NSNumber *)shouldResubscribeOnConnectionRestore;  
	
### Block callback

As was told, most of designated methods contain callback block in it, so events can be handled right away. For each method only last block callback will be triggered (in case if you sent few same requests with handling block, only last one will be triggered).  

### Observation center

[__PNObservationCenter__](3.4/pubnub/libs/PubNub/Core/PNObservationCenter.h) is used in the same way as NSNotificationCenter, but instead of observing with selectors it allow to specify callback block for particular events.  
Blocks described in [__PNStructures.h__](3.4/pubnub/libs/PubNub/Misc/PNStructures.h).  

This is the set of methods which can be used to handle events:  
  
    - (void)addClientConnectionStateObserver:(id)observer  
                           withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;  
	- (void)removeClientConnectionStateObserver:(id)observer;  
	
	- (void)addClientChannelSubscriptionStateObserver:(id)observer  
                                    withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock;  
	- (void)removeClientChannelSubscriptionStateObserver:(id)observer;  
	- (void)addClientChannelUnsubscriptionObserver:(id)observer  
	                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock;  
	- (void)removeClientChannelUnsubscriptionObserver:(id)observer;  
	
	- (void)addTimeTokenReceivingObserver:(id)observer  
                        withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;  
	- (void)removeTimeTokenReceivingObserver:(id)observer;  
	
	- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock;  
	- (void)removeMessageProcessingObserver:(id)observer;  
	
	- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock;  
	- (void)removeMessageReceiveObserver:(id)observer;  
	
	- (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock;  
	- (void)removePresenceEventObserver:(id)observer;  
	
	- (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
	- (void)removeMessageHistoryProcessingObserver:(id)observer;  
	
	- (void)addChannelParticipantsListProcessingObserver:(id)observer  
                                               withBlock:(PNClientParticipantsHandlingBlock)handleBlock;  
	- (void)removeChannelParticipantsListProcessingObserver:(id)observer;  
	
### Notifications

PubNub client also triggers notifications with user information in it, so from any place in your application you can listen for notifications and perform appropriate actions.  
Full list of notifications stored in [__PNNotifications.h__](3.4/pubnub/libs/PubNub/Misc/PNNotifications.h) along with their description and what kind of parameters is sent with them and how to treat them.  