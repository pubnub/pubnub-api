//
//  PNServiceChannel.m
//  pubnub
//
//  This channel is required to manage
//  service message sending to PubNub service.
//  Will send messages like:
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
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNRequestsQueue.h"
#import "PNResponse.h"
#import "PNResponseParser.h"


#pragma mark Private interface methods

@interface PNServiceChannel ()


#pragma mark - Instance methods

/**
 * Check whether response should be processed on
 * this communication channel or not
 */
- (BOOL)shouldHandleResponse:(PNResponse *)response;

- (void)processObservedRequest:(PNBaseRequest *)request withResponse:(PNResponse *)response;


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
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.timeTokenCallback]);
}

- (void)processObservedRequest:(PNBaseRequest *)request withResponse:(PNResponse *)response {

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

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" TIME TOKEN MESSAGE HAS BEEDN PROCESSED");
            [self.serviceDelegate serviceChannel:self didReceiveTimeToken:parser.updateTimeToken];
        }
        else {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PARSED DATA: %@", parser);
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" OBSERVED REQUEST COMPLETED: %@", request);
        }
    }
}


#pragma mark - Connection delegate methods

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {

    if([self shouldHandleResponse:response]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" RECIEVED RESPONSE: %@", response);

        // Checking whether communication channel is waiting
        // for request processing completion confirmation from
        // remote PubNub services or not
        if ([self isWaitingRequestCompletion:response.requestIdentifier]) {

            // Retrieve reference on observer request
            PNBaseRequest *request = [self observedRequestWithIdentifier:response.requestIdentifier];
            [self removeObservationFromRequest:request];

            [self processObservedRequest:request withResponse:response];
        }


        [self scheduleNextRequest];
    }
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" WILL START REQUEST PROCESSING: %@", request);
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];


    // If we are not waiting for request completion, inform delegate
    // immediately
    if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Checking whether request was sent to measure network latency or not
        if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER MESSAGE SENT");
            [(PNLatencyMeasureRequest *)request markStartTime];
        }
    }


    [self scheduleNextRequest];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Forward to the super class
    [super requestsQueue:queue didFailRequestSend:request withError:error];


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

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
        }


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
