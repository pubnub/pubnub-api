//
//  PNConnection.m
//  pubnub
//
//  This is core class for communication over
//  the network with PubNub services.
//  It allow to establish socket connection and
//  organize write packet requests into FIFO queue.
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#import "PNConnection.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "NSMutableArray+PNAdditions.h"
#import "PNConnection+Protected.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNStructures.h"
#import "PNError.h"
#import "PNMacro.h"


#pragma mark - Externs

// Notifications definition
NSString * const kPNConnectionDidConnectNotication = @"PNConnectionDidConnectNotication";
NSString * const kPNConnectionDidDisconnectNotication = @"PNConnectionDidDisconnectNotication";
NSString * const kPNConnectionDidDisconnectWithErrorNotication = @"PNConnectionDidDisconnectWithErrorNotication";
NSString * const kPNConnectionErrorNotification = @"PNConnectionErrorNotification";


#pragma mark - Static

static NSMutableDictionary *_connectionsPool = nil;

// Default origin host connection port
static UInt32 const kPNOriginConnectionPort = 80;

// Default data buffer size (Default: 32kb)
static int const kPNStreamBufferSize = 32768;


#if __IPHONE_OS_VERSION_MIN_REQUIRED
// Stores identifier which is used to store single connection
// which is used on iOS for all kind of requests
static NSString * const kPNSingleConnectionIdentifier = @"PNUniversalConnectionIdentifier";
#endif


#pragma mark - Private interface methods

@interface PNConnection ()

#pragma mark - Properties

// Stores connection name (identifier)
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) PNConfiguration *configuration;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
// Stores list of connection delegates which would like to recieve
// connection events
@property (nonatomic, retain) NSMutableArray *delegates;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
// Stores reference on connection delegate which also will
// be packet provider for connection
@property (nonatomic, weak) id<PNConnectionDelegate> delegate;
#endif

// Stores flag of whether connection should process next
// request from queue or not
@property (nonatomic, assign, getter = shouldProcessNextRequest) BOOL processNextRequest;

// Stores reference on binary data object which stores
// server response from socket read stream
@property (nonatomic, strong) NSMutableData *retrievedData;

// Stores reference on error which is occurred before streams
// life-cycle was started (initialization period)
@property (nonatomic, strong) PNError *intializationError;

// Socket streams and state
@property (nonatomic, assign) CFReadStreamRef socketReadStream;
@property (nonatomic, assign) PNSocketStreamState readStreamState;
@property (nonatomic, assign) CFWriteStreamRef socketWriteStream;
@property (nonatomic, assign) PNSocketStreamState writeStreamState;
@property (nonatomic, strong) NSDictionary *proxySettings;
@property (nonatomic, assign) CFMutableDictionaryRef streamSecuritySettings;


#pragma mark - Class methods

/**
 * Returns reference on dictionary of connections
 * (it will be created on runtime)
 */
+ (NSMutableDictionary *)connectionsPool;


#pragma mark - Instance methods

/**
 * Perform connection intialization with user-provided
 * configuration (they will be obtained from PubNub
 * client)
 */
- (id)initWithConfiguration:(PNConfiguration *)configuration;


#pragma mark - Streams management methods

/**
 * Will create read/write pair streams to specific host at
 */
- (void)prepareStreams;

/**
 * Will terminate any stream activity
 */
- (void)closeStreams;

/**
 * Allow to configure read stream with set of parameters 
 * like:
 *   - proxy
 *   - security (SSL)
 * If stream already configured, it won't accept any new
 * settings.
 */
- (void)configureReadStream:(CFReadStreamRef)readStream;
- (void)openReadStream:(CFReadStreamRef)readStream;
- (void)destroyReadStream:(CFReadStreamRef)readStream;

/**
 * Allow to configure write stream with set of parameters
 * like:
 *   - proxy
 *   - security (SSL)
 * If stream already configured, it won't accept any new
 * settings.
 */
- (void)configureWriteStream:(CFWriteStreamRef)writeStream;
- (void)openWriteStream:(CFWriteStreamRef)writeStream;
- (void)destroyWriteStream:(CFWriteStreamRef)writeStream;


#pragma mark - Handler methods

/**
 * Called every time when one of streams (read/write)
 * successfully open connection
 */
- (void)handleStreamConnection;

/**
 * Called every time when one of streams (read/write)
 * disconnected
 */
- (void)handleStreamClose;

/**
 * Called each time when new portion of data available
 * in socket read stream for reading
 */
- (void)handleReadStreamHasData;

/**
 * Called each time when write stream is ready to accept
 * data from PubNub client
 */
- (void)handleWriteStreamCanAcceptData;

/**
 * Called each time when server close stream because of
 * timeout
 */
- (void)handleStreamTimeout;

/**
 * Converts stream status enum value into string representation
 */
- (NSString *)stringifyStreamStatus:(CFStreamStatus)status;

- (void)handleStreamError:(CFStreamError)error;
- (void)handleStreamError:(CFStreamError)error shouldCloseConnection:(BOOL)shouldCloseConnection;


#pragma mark - Misc methods

/**
 * Connection state retrival
 */
- (BOOL)isConfigured;
- (BOOL)isConnecting;
- (BOOL)isReady;

- (CFStreamClientContext)streamClientContext;

/**
 * Returns dictionary which will allow to configure
 * connection to use SSL depending on configuration
 * provided to PubNub client
 */
- (CFMutableDictionaryRef)streamSecuritySettings;

/**
 * Retrieving global network proxy configuration
 */
- (void)retrieveSystemProxySettings;

/**
 * Stream error processing methods
 */
- (PNError *)processStreamError:(CFStreamError)error;


@end


#pragma mark - Public interface methods

@implementation PNConnection


#pragma mark - Class methods

+ (PNConnection *)connectionWithIdentifier:(NSString *)identifier {
    
    // Try to retrieve connection from pool
    PNConnection *connection = [[self connectionsPool] valueForKey:identifier];
    
    if(connection == nil) {
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        connection = [[self connectionsPool] valueForKey:kPNSingleConnectionIdentifier];
        if (connection == nil) {
            
            // Create new connection initialized with settings retrieved from
            // PubNub configuration object
            connection = [[[self class] alloc] initWithConfiguration:[PubNub sharedInstance].configuration];
            connection.name = kPNSingleConnectionIdentifier;
            [[self connectionsPool] setValue:connection forKey:kPNSingleConnectionIdentifier];
        }
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
        // Create new connection initialized with settings retrieved from
        // PubNub configuration object
        connection = [[[self class] alloc] initWithConfiguration:[PubNub sharedInstance].configuration];
        connection.name = identifier;
#endif
        [[self connectionsPool] setValue:connection forKey:identifier];
    }
    
    
    return connection;
}

+ (void)destroyConnection:(PNConnection *)connection {
    
    if (connection != nil) {
        
        // Iterate over the list of connection pool and remove
        // connection from it
        NSMutableArray *connectionIdentifiersForDelete = [NSMutableArray array];
        [[self connectionsPool] enumerateKeysAndObjectsUsingBlock:^(id connectionIdentifier,
                                                                    id connectionFromPool,
                                                                    BOOL *connectionEnumeratorStop) {
            
            // Check whether found connection in connection pool or not
            if (connectionFromPool == connection) {
                
                [connectionIdentifiersForDelete addObject:connectionIdentifier];
            }
        }];
        
        [[self connectionsPool] removeObjectsForKeys:connectionIdentifiersForDelete];
        
    }
}

+ (void)closeAllConnections {
    
    // Check whether has some connection in pool or not
    if ([_connectionsPool count] > 0) {
        
        // Store list of connections before purge connections pool
        NSArray *connections = [_connectionsPool allValues];
        
        
        // Clean up connections pool
        [_connectionsPool removeAllObjects];
        
        
        // Close all connections
        [connections makeObjectsPerformSelector:@selector(closeStreams)];
    }
}

+ (NSMutableDictionary *)connectionsPool {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _connectionsPool = [NSMutableDictionary new];
    });
    
    
    return _connectionsPool;
}


#pragma mark - Instance methods

- (id)initWithConfiguration:(PNConfiguration *)configuration {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        // Perform connection initialization
        self.configuration = configuration;
        [self prepareStreams];
    }
    
    
    return self;
}


#pragma mark - Requests queue execution management

- (void)scheduleNextRequestExecution {
    
    // TODO: CHECK WHETHER IS SENDING REQUEST AT THIS
    //       MOMENT OR NOT
    
    self.processNextRequest = YES;
    
    
    // Check whether connection ready and there is data source which will provide pacekts for execution
    if([self isConnected]) {
        
        // Check whether data source can provide some
        // data right after connection is established
        // or not
        if ([self.dataSource hasDataForConnection:self]) {
            
            
        }
    }
}

- (void)unscheduleRequestsExecution {
    
    self.processNextRequest = NO;
}


#pragma mark - Streams management methods

void readStreamCallback(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
    
    NSCAssert([(__bridge id)clientCallBackInfo isKindOfClass:[PNConnection class]],
              @"{ERROR}[READ] WRONG CLIENT INSTANCE HAS BEEN SENT AS CLIENT");
    PNConnection *connection = (__bridge PNConnection *)clientCallBackInfo;
    
    switch (type) {
        case kCFStreamEventOpenCompleted:
            
            PNCLog(@"{INFO}[CONNECTION::%@::READ] STREAM OPENED (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFReadStreamGetStatus(stream)]);
            
            connection.readStreamState = PNSocketStreamConnected;
            [connection handleStreamConnection];
            break;
        case kCFStreamEventHasBytesAvailable:
            
            PNCLog(@"{INFO}[CONNECTION::%@::READ] HAS DATA FOR READ OUT (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFReadStreamGetStatus(stream)]);
            
            [connection handleReadStreamHasData];
            break;
        case kCFStreamEventErrorOccurred:
            
            PNCLog(@"{INFO}[CONNECTION::%@::READ] ERROR OCCURRED (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFReadStreamGetStatus(stream)]);
            
            [connection handleStreamError:CFReadStreamGetError(stream) shouldCloseConnection:YES];
            break;
        case kCFStreamEventEndEncountered:
            
            PNCLog(@"{INFO}[CONNECTION::%@::READ] NOTHING TO READ (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFReadStreamGetStatus(stream)]);
            
            [connection handleStreamTimeout];
            break;
            
        default:
            break;
    }
}

void writeStreamCallback(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
    
    NSCAssert([(__bridge id)clientCallBackInfo isKindOfClass:[PNConnection class]],
              @"{ERROR}[WRITE] WRONG CLIENT INSTANCE HAS BEEN SENT AS CLIENT");
    PNConnection *connection = (__bridge PNConnection *)clientCallBackInfo;
    
    switch (type) {
        case kCFStreamEventOpenCompleted:
            
            PNCLog(@"{INFO}[CONNECTION::%@::WRITE] STREAM OPENED (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFWriteStreamGetStatus(stream)]);
            
            connection.writeStreamState = PNSocketStreamConnected;
            [connection handleStreamConnection];
            break;
        case kCFStreamEventCanAcceptBytes:
            
            PNCLog(@"{INFO}[CONNECTION::%@::WRITE] READY TO SEND (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFWriteStreamGetStatus(stream)]);
            break;
        case kCFStreamEventErrorOccurred:
            
            PNCLog(@"{INFO}[CONNECTION::%@::WRITE] ERROR OCCURRED (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFWriteStreamGetStatus(stream)]);
            
            [connection handleStreamError:CFWriteStreamGetError(stream) shouldCloseConnection:YES];
            break;
        case kCFStreamEventEndEncountered:
            
            PNCLog(@"{INFO}[CONNECTION::%@::WRITE] MAYBE STREAM IS CLOSED (%@)",
                   connection.name,
                   [connection stringifyStreamStatus:CFWriteStreamGetStatus(stream)]);
            
            [connection handleStreamTimeout];
            break;
            
        default:
            break;
    }
}

- (void)prepareStreams {
    
    // Check whether stream was prepared and configured before
    if([self isConfigured] || [self isConnected] || [self isReady]) {
        
        PNLog(@"{INFO}[CONNECTION::%@] SOCKET AND STREAMS ALREADY CONFIGURATED", self.name);
    }
    else {
    
        // Create stream pair on socket which is connected to
        // specified remote host
        CFStreamCreatePairWithSocketToHost(CFAllocatorGetDefault(),
                                           (__bridge CFStringRef)(self.configuration.origin),
                                           kPNOriginConnectionPort,
                                           &_socketReadStream,
                                           &_socketWriteStream);
        
        // Configure default socket stream states
        self.writeStreamState = PNSocketStreamNotConfigured;
        self.readStreamState = PNSocketStreamNotConfigured;
        [self configureReadStream:self.socketReadStream];
        [self configureWriteStream:self.socketWriteStream];
        if(self.readStreamState != PNSocketStreamReady || self.writeStreamState != PNSocketStreamReady) {
            
            [self closeStreams];
        }
    }
}

- (void)closeStreams {
    
    // Clean up cached data
    _proxySettings = nil;
    if(_streamSecuritySettings != NULL) {
        
        CFRelease(_streamSecuritySettings), _streamSecuritySettings = NULL;
    }
    
    
    [self destroyReadStream:self.socketReadStream];
    [self destroyWriteStream:self.socketWriteStream];
}

- (BOOL)connect {
    
    BOOL isStreamOpened = NO;
    
    if(![self isConnected] && [self isReady]) {
        
        if (![self isConnecting]) {
            
            [self openReadStream:self.socketReadStream];
            [self openWriteStream:self.socketWriteStream];
        }
        
        isStreamOpened = YES;
    }
    // Looks like streams not ready yet (maybe stream closed
    // during previous session)
    else if(![self isReady] && ![self isConnected]){
        
        if (![self isConnecting]) {
        
            [self prepareStreams];
            [self connect];
        }
    }
    
    
    return isStreamOpened;
}

- (BOOL)isReady {
    
    return (self.readStreamState == PNSocketStreamReady && self.writeStreamState == PNSocketStreamReady);
}

- (BOOL)isConfigured {
    
    return (self.readStreamState != PNSocketStreamNotConfigured && self.writeStreamState != PNSocketStreamNotConfigured);
}

- (BOOL)isConnecting {
    
    return (self.readStreamState == PNSocketStreamConnecting && self.writeStreamState == PNSocketStreamConnecting);
}

- (BOOL)isConnected {
    
    return (self.readStreamState == PNSocketStreamConnected && self.writeStreamState == PNSocketStreamConnected);
}

- (BOOL)isDisconnected {
    
    return (self.readStreamState == PNSocketStreamNotConfigured && self.writeStreamState == PNSocketStreamNotConfigured);
}

- (void)closeConnection {
    
    [self closeStreams];
}

- (void)configureReadStream:(CFReadStreamRef)readStream {
    
    if (self.readStreamState != PNSocketStreamNotConfigured) {
        
        [self destroyReadStream:readStream];
    }
    
    
    CFOptionFlags options = (kCFStreamEventOpenCompleted|kCFStreamEventHasBytesAvailable|
                             kCFStreamEventErrorOccurred|kCFStreamEventEndEncountered);
    CFStreamClientContext client = [self streamClientContext];
    
    BOOL isStreamReady = CFReadStreamSetClient(readStream, options, readStreamCallback, &client);
    
    // Configure proxy settings only for insecure connection
    if (self.streamSecuritySettings == NULL && self.proxySettings != nil) {
        
        isStreamReady = CFReadStreamSetProperty(readStream,
                                                kCFStreamPropertyHTTPProxy,
                                                (__bridge CFDictionaryRef)(self.proxySettings));
    }
    
    if (self.streamSecuritySettings != NULL && isStreamReady) {
        
        // Specify connection security options
        isStreamReady = CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, self.streamSecuritySettings);
    }
    
    
    if (isStreamReady) {
        
        self.readStreamState = PNSocketStreamReady;
        
        
        // Schedule read stream on current runloop
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
}

- (void)destroyReadStream:(CFReadStreamRef)readStream {
    
    BOOL shouldCloseStream = self.readStreamState == PNSocketStreamConnected;
    self.readStreamState = PNSocketStreamNotConfigured;
    
    
    if (readStream != NULL) {
        
        
        // Destroying input buffer
        _retrievedData = nil;
        
        
        // Unschedule read stream from runloop
        CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamSetClient(readStream, kCFStreamEventNone, NULL, NULL);
        
        // Checking whether read stream is opened and
        // close it if required
        if (shouldCloseStream) {
            
            CFReadStreamClose(readStream);
        }
        CFRelease(readStream);
        self.socketReadStream = NULL;
        
        
        if (shouldCloseStream) {
            
            [self handleStreamClose];
        }
    }
}

- (void)openReadStream:(CFReadStreamRef)readStream {
    
    self.readStreamState = PNSocketStreamConnecting;
    
    if (!CFReadStreamOpen(readStream)) {
        
        CFStreamError error = CFReadStreamGetError(readStream);
        if (error.error != 0) {
            
            self.readStreamState = PNSocketStreamError;
            [self handleStreamError:error];
        }
        else {
            
            CFRunLoopRun();
        }
    }
}

- (void)configureWriteStream:(CFWriteStreamRef)writeStream {
    
    if (self.writeStreamState != PNSocketStreamNotConfigured) {
        
        [self destroyWriteStream:writeStream];
    }
    
    CFOptionFlags options = (kCFStreamEventOpenCompleted|kCFStreamEventCanAcceptBytes|
                             kCFStreamEventErrorOccurred|kCFStreamEventEndEncountered);
    CFStreamClientContext client = [self streamClientContext];
    
    BOOL isStreamReady = CFWriteStreamSetClient(writeStream, options, writeStreamCallback, &client);
    
    // Configure proxy settings only for insecure connection
    if (self.streamSecuritySettings == NULL && self.proxySettings != nil) {
        
        isStreamReady = CFWriteStreamSetProperty(writeStream,
                                                 kCFStreamPropertyHTTPProxy,
                                                 (__bridge CFDictionaryRef)(self.proxySettings));
    }
    
    if (self.streamSecuritySettings != NULL && isStreamReady) {
        
        // Specify connection security options
        isStreamReady = CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, self.streamSecuritySettings);
    }
    
    
    if (isStreamReady) {
        
        self.writeStreamState = PNSocketStreamReady;
        
        
        // Schedule write stream on current runloop
        CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
}

- (void)openWriteStream:(CFWriteStreamRef)writeStream {
    
    self.writeStreamState = PNSocketStreamConnecting;
    
    if (!CFWriteStreamOpen(writeStream)) {
        
        CFStreamError error = CFWriteStreamGetError(writeStream);
        if (error.error != 0) {
            
            self.writeStreamState = PNSocketStreamError;
            [self handleStreamError:error];
        }
        else {
            
            CFRunLoopRun();
        }
    }
}

- (void)destroyWriteStream:(CFWriteStreamRef)writeStream {
    
    BOOL shouldCloseStream = self.writeStreamState == PNSocketStreamConnected;
    self.writeStreamState = PNSocketStreamNotConfigured;
    
    
    if (writeStream != NULL) {
        
        
        // Unschedule write stream from runloop
        CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFWriteStreamSetClient(writeStream, kCFStreamEventNone, NULL, NULL);
        
        // Checking whether write stream is opened and
        // close it if required
        if (shouldCloseStream) {
            
            CFWriteStreamClose(writeStream);
        }
        CFRelease(writeStream);
        self.socketWriteStream = NULL;
        
        if (shouldCloseStream) {
            
            [self handleStreamClose];
        }
    }
}


#pragma mark - Handler methods

- (void)handleStreamConnection {
    
    if (self.readStreamState == PNSocketStreamConnected && self.writeStreamState == PNSocketStreamConnected) {
        
        __block __pn_desired_weak PNConnection *weakSelf = self;
        [[self delegates] enumerateObjectsUsingBlock:^(id<PNConnectionDelegate> delegate,
                                                       NSUInteger delegateIdx,
                                                       BOOL *delegateEnumeratorStop) {
            
            [delegate connection:weakSelf didConnectToHost:weakSelf.configuration.origin];
        }];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPNConnectionDidConnectNotication
                                                            object:self
                                                          userInfo:nil];
    }
}

- (void)handleStreamClose {
    
    if (self.readStreamState == PNSocketStreamNotConfigured && self.writeStreamState == PNSocketStreamNotConfigured) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPNConnectionDidDisconnectNotication
                                                            object:self
                                                          userInfo:nil];
        
        __block __pn_desired_weak PNConnection *weakSelf = self;
        [[self delegates] enumerateObjectsUsingBlock:^(id<PNConnectionDelegate> delegate,
                                                 NSUInteger delegateIdx,
                                                 BOOL *delegateEnumeratorStop) {
            
            [delegate connection:weakSelf didDisconnectFromHost:weakSelf.configuration.origin];
        }];
    }
}

- (void)handleReadStreamHasData {
    
    if (CFReadStreamHasBytesAvailable(self.socketReadStream)) {
        
        UInt8 buffer[kPNStreamBufferSize];
        CFIndex readedBytesCount = CFReadStreamRead(self.socketReadStream, buffer, kPNStreamBufferSize);
        if (readedBytesCount > 0) {
            
            // Store fetched data
            [self.retrievedData appendBytes:buffer length:readedBytesCount];
            
            // TODO: PROCESS DATA AND TRY TO EXTRACT COMPLETED RESPONSE FROM IT
        }
        else if(readedBytesCount == 0) {
            
            // TODO: PROCESS NO DATA
        }
        else {
            
            [self handleStreamError:CFReadStreamGetError(self.socketReadStream)];
        }
    }
}

- (void)handleWriteStreamCanAcceptData {
    
    
}

- (void)handleStreamTimeout {
    
    [self closeStreams];
}

- (NSString *)stringifyStreamStatus:(CFStreamStatus)status {
    
    NSString *stringifiedStatus = @"NOTHING INTERESTING";
    
    switch (status) {
        case kCFStreamStatusNotOpen:
            
            stringifiedStatus = @"STREAM NOT OPENED";
            break;
        case kCFStreamStatusOpening:
            
            stringifiedStatus = @"STREAM IS OPENING";
            break;
        case kCFStreamStatusOpen:
            
            stringifiedStatus = @"STREAM IS OPENED";
            break;
        case kCFStreamStatusReading:
            
            stringifiedStatus = @"READING FROM STREAM";
            break;
        case kCFStreamStatusWriting:
            
            stringifiedStatus = @"WRITING INTO STREAM";
            break;
        case kCFStreamStatusAtEnd:
            
            stringifiedStatus = @"STREAM CAN'T READ/WRITE DATA";
            break;
        case kCFStreamStatusClosed:
            
            stringifiedStatus = @"STREAM CLOSED";
            break;
        case kCFStreamStatusError:
            
            stringifiedStatus = @"STREAM ERROR OCCURRED";
            break;
    }
    
    
    return stringifiedStatus;
}

- (void)handleStreamError:(CFStreamError)error {
    
    [self handleStreamError:error shouldCloseConnection:NO];
}

- (void)handleStreamError:(CFStreamError)error shouldCloseConnection:(BOOL)shouldCloseConnection {
    
    if (error.error != 0) {
        
        PNError *errorObject = [self processStreamError:error];
        
        if(shouldCloseConnection) {
            
            [[self delegates] enumerateObjectsUsingBlock:^(id<PNConnectionDelegate> delegate,
                                                           NSUInteger delegateIdx,
                                                           BOOL *delegateEnumeratorStop) {
                
                [delegate connection:self willDisconnectFromHost:self.configuration.origin withError:errorObject];
            }];
            
            [self closeStreams];
        }
        else {
            
            [[self delegates] enumerateObjectsUsingBlock:^(id<PNConnectionDelegate> delegate,
                                                           NSUInteger delegateIdx,
                                                           BOOL *delegateEnumeratorStop) {
                
                [delegate connection:self connectionDidFailToHost:self.configuration.origin withError:errorObject];
            }];
        }
    }
}


#pragma mark - Misc methods

- (void)assignDelegate:(id<PNConnectionDelegate>)delegate {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    
    [[self delegates] addObject:delegate];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    
    _delegate = delegate;
#endif
}

- (void)resignDelegate:(id<PNConnectionDelegate>)delegate {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    
    [[self delegates] removeObject:delegate];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    
    _delegate = delegate;
#endif
}

- (CFStreamClientContext)streamClientContext {
    
    return (CFStreamClientContext){0, (__bridge void *)(self), NULL, NULL, NULL};
}

- (CFMutableDictionaryRef)streamSecuritySettings {
    
    if (self.configuration.shouldUseSecureConnection && _streamSecuritySettings == NULL) {
        
        // Configure security settings
        _streamSecuritySettings = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 6, NULL, NULL);
        CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelNegotiatedSSL);
        CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanFalse);
        CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLValidatesCertificateChain, kCFBooleanTrue);
        CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsExpiredRoots, kCFBooleanFalse);
        CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
        CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLPeerName, kCFNull);
    }
    else if(!self.configuration.shouldUseSecureConnection && _streamSecuritySettings != NULL) {
        
        CFRelease(_streamSecuritySettings);
        _streamSecuritySettings = NULL;
    }
    
    
    return _streamSecuritySettings;
}

/**
 * Reloading property to handle connection instance
 * to have multiple delegates when running on iOS and
 * only one delegate on Mac OS
 */
- (NSMutableArray *)delegates {

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    if(_delegates == nil) {
        
        _delegates = [NSMutableArray arrayUsingWeakReferences];
    };
    
    
    return _delegates;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    return @[self.delegate];
#endif
    
    
    return nil;
}

- (void)retrieveSystemProxySettings {
    
    if (self.proxySettings == NULL) {
        
        self.proxySettings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    }
}

/**
 * Lazy data holder creation
 */
- (NSMutableData *)retrievedData {
    
    if (_retrievedData == nil) {
        
        _retrievedData = [NSMutableData dataWithCapacity:kPNStreamBufferSize];
    }
    
    
    return _retrievedData;
}

- (PNError *)processStreamError:(CFStreamError)error {
    
    NSString *domain = error.domain == kCFStreamErrorDomainMacOSStatus?NSOSStatusErrorDomain:NSPOSIXErrorDomain;
    
    
    return (PNError *)[NSError errorWithDomain:domain code:error.error userInfo:nil];
}


#pragma mark - Memory management

- (void)dealloc {
    
    // Closing all streams and free up resources
    // which was allocated for their support
    [self closeConnection];
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    _delegates = nil;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    _delegate = nil;
#endif
    _proxySettings = nil;
    if(_streamSecuritySettings != NULL) {
        
        CFRelease(_streamSecuritySettings), _streamSecuritySettings = NULL;
    }
}

#pragma mark -


@end
