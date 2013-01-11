//
//  PNServiceChannel.m
//  pubnub
//
//  This channel is required to manage
//  service message sending to PubNub service.
//  Will send messages like:
//      - publish
//      - time
//      - history
//      - here now (list of participants)
//      - "ping" (latency measurement if enabled)
//
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//  
//
//  Created by Sergey Mamontov on 12/15/12.
//
//

#import "PNServiceChannel.h"
#import "PNConnectionChannel+Protected.h"
#import "PNServiceChannelDelegate.h"
#import "PNLatencyMeasureRequest.h"
#import "PNConnection+Protected.h"
#import "PNMessage+Protected.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNResponseParser.h"
#import "PNRequestsQueue.h"
#import "PNResponse.h"


#pragma mark Private interface methods

@interface PNServiceChannel ()


#pragma mark - Instance methods

/**
 * Check whether response should be processed on
 * this communication channel or not
 */
- (BOOL)shouldHandleResponse:(PNResponse *)response;

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request;


#pragma mark - Handler methods

/**
 * Called every time when message sending request
 * processing completed
 */
- (void)handleMessageRequestCompletion:(PNMessagePostRequest *)request withResponse:(PNResponse *)response;


@end


#pragma mark - Public interface methods

@implementation PNServiceChannel


#pragma mark - Class methods

/**
 * Return reference on configured service communication
 * channel with specified delegate
 */
+ (PNServiceChannel *)serviceChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate {

    return [super connectionChannelWithType:PNConnectionChannelService
                                andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if((self = [super initWithType:PNConnectionChannelService andDelegate:delegate])) {

    }


    return self;
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {
    
    return ([response.callbackMethod hasPrefix:PNServiceResponseCallbacks.latencyMeasureMessageCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.timeTokenCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.sendMessageCallback]);
}

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER MESSAGE HAS BEEN PROCESSED");
        [(PNLatencyMeasureRequest *)request markEndTime];

        // Notify delegate that network metrics gathered
        [self.serviceDelegate serviceChannel:self
                    didReceiveNetworkLatency:[(PNLatencyMeasureRequest *)request latency]
                         andNetworkBandwidth:[(PNLatencyMeasureRequest *)request bandwidthToLoadResponse:response]];
    }
    else {

        PNResponseParser *parser = [PNResponseParser parserForResponse:response];

        // Check whether request is 'Time token' request or not
        if ([request isKindOfClass:[PNTimeTokenRequest class]]){

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" TIME TOKEN MESSAGE HAS BEEN PROCESSED");
            [self.serviceDelegate serviceChannel:self didReceiveTimeToken:parser.updateTimeToken];
        }
        // Check whether request was sent for message posting
        else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            [self handleMessageRequestCompletion:(PNMessagePostRequest *)request withResponse:response];
        }
        else {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PARSED DATA: %@", parser);
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" OBSERVED REQUEST COMPLETED: %@", request);
        }
    }
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
        [self.serviceDelegate serviceChannel:self didFailMessageSend:messageObject withError:error];
    }


    return messageObject;
}

- (void)sendMessage:(PNMessage *)message {

    if (message) {

        // Schedule message sending request
        [self sendMessage:message.message toChannel:message.channel];
    }
}


#pragma mark - Handler methods

- (void)handleMessageRequestCompletion:(PNMessagePostRequest *)request withResponse:(PNResponse *)response {

    PNResponseParser *parser = [PNResponseParser parserForResponse:response];

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" MESSAGE SENDING RESPONSE: %@", parser);

    // Notify delegate about that message post request will be sent now
    [self.serviceDelegate serviceChannel:self didSendMessage:request.message];
}


#pragma mark - Connection delegate methods

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {

    if ([self shouldHandleResponse:response]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" RECIEVED RESPONSE: %@", response);

        // Retrieve reference on observer request
        PNBaseRequest *request = [self observedRequestWithIdentifier:response.requestIdentifier];
        [self destroyRequest:request];

        [self processResponse:response forRequest:request];


        // Check whether connection available or not
        if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

            // Asking to schedule next request
            [self scheduleNextRequest];
        }
    }
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" WILL START REQUEST PROCESSING: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // Check whether this is 'Message post' request or not
    if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message post request will be sent now
        [self.serviceDelegate serviceChannel:self willSendMessage:((PNMessagePostRequest *)request).message];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID SEND REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // If we are not waiting for request completion, inform delegate
    // immediately
    if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Checking whether request was sent to measure network latency or not
        if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER MESSAGE SENT");
            [(PNLatencyMeasureRequest *)request markStartTime];
        }
    }
    else {

        // Check whether this is 'Post message' request or not
        if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            [self handleMessageRequestCompletion:request withResponse:nil];
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


    // Check whether request can be rescheduled or not
    if (![request canRetry]) {

        // Removing failed request from queue
        [self destroyRequest:request];


        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" REQUEST PROCESSING FAILED: %@", request);

        // Check whether request is 'Latency meter' request or not
        if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

            PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" LATENCY METER REQUEST SENDING FAILED");
        }
        // Check whether request is 'Time token' request or not
        else if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

            [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:error];
        }
        // Check whether this is 'Post message' request or not
        else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            // Notify delegate about that message can't be send
            [self.serviceDelegate serviceChannel:self
                              didFailMessageSend:((PNMessagePostRequest *)request).message
                                       withError:error];
        }
    }


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        [self scheduleNextRequest];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didCancelRequest:request];

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER REQUEST CANCELED");

        // Removing 'Latency meter' request because PubNub client
        // is not interested in delayed response on network measurements
        [self destroyRequest:request];
    }
}

- (BOOL)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request {

    BOOL shouldRemoveRequest = YES;

    // Check whether leave request has been sent to PubNub
    // services or not
    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        shouldRemoveRequest = NO;
    }


    return shouldRemoveRequest;
}

#pragma mark -


@end
