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
#import <Security/SecureTransport.h>
#import "PNResponseDeserialize.h"
#import "PubNub+Protected.h"
#import "PNWriteBuffer.h"


#pragma mark Structures

typedef enum _PNConnectionSSLConfigurationLevel {

    // This option will check all information on
    // remote origin SSL certificate to ensure in
    // authority
    PNConnectionSSLConfigurationStrict,

    // This option will skip most of validations
    // and as fact will allow to work with server
    // which uses invalid SSL certificate or certificate
    // from another server
    PNConnectionSSLConfigurationBarelySecure,

    // This option will tell that connection should
    // be opened w/o SSL (if user won't to discard
    // security options)
    PNConnectionSSLConfigurationInSecure,
} PNConnectionSSLConfigurationLevel;


#pragma mark - Static

// Stores reference on created connection instances
// which can be used/reused
static NSMutableDictionary *_connectionsPool = nil;

// Default origin host connection port
static UInt32 const kPNOriginConnectionPort = 80;

// Default origin host SSL connection port
static UInt32 const kPNOriginSSLConnectionPort = 443;

// Default data buffer size (Default: 32kb)
static int const kPNStreamBufferSize = 32768;


#pragma mark - Private interface methods

@interface PNConnection ()

#pragma mark - Properties

// Stores connection name (identifier)
@property (nonatomic, copy) NSString *name;

// Connection configuration information
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores flag of whether connection should process next
// request from queue or not
@property (nonatomic, assign, getter = shouldProcessNextRequest) BOOL processNextRequest;

// Stores flag on whether connecion is closing or not
@property (nonatomic, assign, getter = isClosingConnection) BOOL closingConnection;

// Stores whether connection instance is reconnecting at
// this moment (which will mean that it should automatically
// open connection after full close)
@property (nonatomic, assign, getter = isReconnecting) BOOL reconnecting;

// Stores reference on response deserializer which will parse
// response into objects array and update provided data to
// insert offset on amount of parsed data
@property (nonatomic, strong) PNResponseDeserialize *deserializer;

// Stores reference on binary data object which stores
// server response from socket read stream
@property (nonatomic, strong) NSMutableData *retrievedData;

// Stores reference on binary data object which temporary
// stores data received from socket read stream (used while
// deserializer is working)
@property (nonatomic, strong) NSMutableData *temporaryRetrievedData;

// Stores reference on buffer which should be sent to
// the PubNub service via socket
@property (nonatomic, strong) PNWriteBuffer *writeBuffer;

// Socket streams and state
@property (nonatomic, assign) CFReadStreamRef socketReadStream;
@property (nonatomic, assign) PNSocketStreamState readStreamState;
@property (nonatomic, assign) CFWriteStreamRef socketWriteStream;
@property (nonatomic, assign) PNSocketStreamState writeStreamState;
@property (nonatomic, assign, getter = isWriteStreamCanHandleData) BOOL writeStreamCanHandleData;

// Socket streams configuration and security
@property (nonatomic, strong) NSDictionary *proxySettings;
@property (nonatomic, assign) CFMutableDictionaryRef streamSecuritySettings;
@property (nonatomic, assign) PNConnectionSSLConfigurationLevel sslConfigurationLevel;


#pragma mark - Class methods

/**
 * Retrieve reference on connection with specified identifier
 * from connections pool
 */
+ (PNConnection *)connectionFromPoolWithIdentifier:(NSString *)identifier;

/**
 * Store connection instance inside connections pool
 */
+ (void)storeConnection:(PNConnection *)connection withIdentifier:(NSString *)identifier;

/**
 * Returns reference on dictionary of connections
 * (it will be created on runtime)
 */
+ (NSMutableDictionary *)connectionsPool;


#pragma mark - Instance methods

/**
 * Perform connection initialization with user-provided
 * configuration (they will be obtained from PubNub
 * client)
 */
- (id)initWithConfiguration:(PNConfiguration *)configuration;


#pragma mark - Streams management methods

/**
 * Will create read/write pair streams to specific host at
 */
- (BOOL)prepareStreams;

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
 * Process response which was fetched from read stream
 * so far
 */
- (void)processResponse;

/**
 * Read out content which is waiting in
 * read stream
 */
- (void)readStreamContent;

/**
 * Allow to complete write stream configuration (additional
 * settings will be transferred from paired read stream on
 * configuration)
 * If stream already configured, it won't accept any new
 * settings.
 */
- (void)configureWriteStream:(CFWriteStreamRef)writeStream;

- (void)openWriteStream:(CFWriteStreamRef)writeStream;

- (void)destroyWriteStream:(CFWriteStreamRef)writeStream;

/**
 * Retrieve and prepare next request which should be sent
 */
- (void)prepareNextRequestPacket;

/**
 * Writes buffer portion into socket
 */
- (void)writeBufferContent;


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

- (void)handleStreamError:(CFErrorRef)error;

- (void)handleStreamError:(CFErrorRef)error shouldCloseConnection:(BOOL)shouldCloseConnection;

- (void)handleStreamSetupError;

- (void)handleRequestProcessingError:(CFErrorRef)error;


#pragma mark - Misc methods

/**
 * Check whether specified error is from POSIX domain
 * and report that error is caused by connection failure
 * or not
 */
- (BOOL)isConnectionIssuesError:(CFErrorRef)error;

/**
 * Connection state retrieval
 */
- (BOOL)isConfigured;

- (BOOL)isConnecting;

- (BOOL)isReady;

- (CFStreamClientContext)streamClientContext;

/**
 * Retrieving global network proxy configuration
 */
- (void)retrieveSystemProxySettings;

/**
 * Stream error processing methods
 */
- (PNError *)processStreamError:(CFErrorRef)error;


@end


#pragma mark - Public interface methods

@implementation PNConnection


#pragma mark - Class methods

+ (PNConnection *)connectionWithIdentifier:(NSString *)identifier {

    // Try to retrieve connection from pool
    PNConnection *connection = [self connectionFromPoolWithIdentifier:identifier];

    if (connection == nil) {

        connection = [[[self class] alloc] initWithConfiguration:[PubNub sharedInstance].configuration];
        connection.name = identifier;
        [self storeConnection:connection withIdentifier:identifier];
    }


    return connection;
}

+ (PNConnection *)connectionFromPoolWithIdentifier:(NSString *)identifier {

    return [[self connectionsPool] valueForKey:identifier];
}

+ (void)storeConnection:(PNConnection *)connection withIdentifier:(NSString *)identifier {

    [[self connectionsPool] setValue:connection forKey:identifier];
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

                // Adding identifier to the list of keys which should be removed
                // (there can be many keys for single connection because of performance
                // and network issues on iOS)
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
    if ((self = [super init])) {

        // Perform connection initialization
        self.configuration = configuration;
        self.deserializer = [PNResponseDeserialize new];

        // Perform streams initial options and security initializations
        [self prepareStreams];
    }


    return self;
}


#pragma mark - Requests queue execution management

- (void)scheduleNextRequestExecution {

    self.processNextRequest = YES;

    // Checking whether we have write buffer with data
    // or not
    if (self.writeBuffer == nil || ![self.writeBuffer hasData]) {

        self.writeBuffer = nil;


        // Check whether connection ready and there is data source which will provide packets for execution
        if ([self isConnected]) {

            [self prepareNextRequestPacket];

            // Try to initiate request sending process
            [self writeBufferContent];
        }
    }
    // Check whether write buffer already created, has data and because of some
    // reasons not processing and not sending data to the remote server
    else if(self.writeBuffer != nil && [self.writeBuffer hasData] &&
            [self.writeBuffer isPartialDataSent] && !self.writeBuffer.isSendingBytes) {

        [self writeBuffer];
    }

}

- (void)unscheduleRequestsExecution {

    self.processNextRequest = NO;
}


#pragma mark - Streams callback methods

void readStreamCallback(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {

    NSCAssert([(__bridge id)clientCallBackInfo isKindOfClass:[PNConnection class]],
    @"{ERROR}[READ] WRONG CLIENT INSTANCE HAS BEEN SENT AS CLIENT");
    PNConnection *connection = (__bridge PNConnection *)clientCallBackInfo;

    NSString *status = [connection stringifyStreamStatus:CFReadStreamGetStatus(stream)];

    switch (type) {

        // Stream successfully opened
        case kCFStreamEventOpenCompleted:

            PNLog(PNLogConnectionLayerInfoLevel, connection, @"[CONNECTION::%@::READ] STREAM OPENED (%@)", connection.name, status);

            connection.readStreamState = PNSocketStreamConnected;
            [connection handleStreamConnection];
            break;

        // Read stream has some data which arrived from
        // remote server
        case kCFStreamEventHasBytesAvailable:

            PNLog(PNLogConnectionLayerInfoLevel, connection, @"[CONNECTION::%@::READ] HAS DATA FOR READ OUT (%@)", connection.name, status);

            [connection handleReadStreamHasData];
            break;

        // Some error occurred on read stream
        case kCFStreamEventErrorOccurred:

            PNLog(PNLogConnectionLayerErrorLevel, connection, @"[CONNECTION::%@::READ] ERROR OCCURRED (%@)",
                  connection.name, status);

            CFErrorRef error = CFReadStreamCopyError(stream);
            [connection handleStreamError:error shouldCloseConnection:YES];

            PNCFRelease(&error);
            break;

        // Server disconnected socket and read stream
        // and probably because of timeout
        case kCFStreamEventEndEncountered:

            PNLog(PNLogConnectionLayerInfoLevel, connection, @"[CONNECTION::%@::READ] NOTHING TO READ (%@)", connection.name, status);

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

    NSString *status = [connection stringifyStreamStatus:CFWriteStreamGetStatus(stream)];

    switch (type) {

        // Stream successfully opened
        case kCFStreamEventOpenCompleted:

            PNLog(PNLogConnectionLayerInfoLevel, connection, @"[CONNECTION::%@::WRITE] STREAM OPENED (%@)", connection.name, status);

            connection.writeStreamState = PNSocketStreamConnected;
            [connection handleStreamConnection];
            break;

        // Write stream is ready to accept data from
        // data source
        case kCFStreamEventCanAcceptBytes:

            PNLog(PNLogConnectionLayerInfoLevel, connection, @"[CONNECTION::%@::WRITE] READY TO SEND (%@)", connection.name, status);

            [connection handleWriteStreamCanAcceptData];
            break;

        // Some error occurred on write stream
        case kCFStreamEventErrorOccurred:

            PNLog(PNLogConnectionLayerErrorLevel, connection, @"[CONNECTION::%@::WRITE] ERROR OCCURRED (%@)",
                  connection.name, status);

            CFErrorRef error = CFWriteStreamCopyError(stream);
            [connection handleStreamError:error shouldCloseConnection:YES];

            PNCFRelease(&error);
            break;

        // Server disconnected socket and write stream
        // and probably because of timeout
        case kCFStreamEventEndEncountered:

            PNLog(PNLogConnectionLayerInfoLevel, connection, @"[CONNECTION::%@::WRITE] MAYBE STREAM IS CLOSED (%@)", connection.name, status);

            [connection handleStreamTimeout];
            break;

        default:
            break;
    }
}


#pragma mark - Connection state

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

- (BOOL)isConnectionIssuesError:(CFErrorRef)error {

    BOOL isConnectionIssue = NO;


    NSString *errorDomain = (__bridge NSString *)CFErrorGetDomain(error);

    if ([errorDomain isEqualToString:(NSString *)kCFErrorDomainPOSIX]) {

        switch (CFErrorGetCode(error)) {

            case ENETDOWN:      // Network went down
            case ENETUNREACH:   // Network is unreachable
            case ECONNABORTED:  // Connection was aborted by software (OS)
            case ENETRESET:     // Network dropped connection on reset
            case ECONNRESET:    // Connection reset by peer
            case ENOTCONN:      // Socket not connected or was disconnected
            case ESHUTDOWN:     // Can't send after socket shutdown
            case EHOSTDOWN:     // Host is down
            case EHOSTUNREACH:  // Can't reach host
            case ETIMEDOUT:     // Socket timeout
            case EPIPE:         // Something went wrong and pipe was dameged

                isConnectionIssue = YES;
                break;
        }
    }
    else if ([errorDomain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {

        switch (CFErrorGetCode(error)) {

            case kCFHostErrorHostNotFound:
            case kCFHostErrorUnknown:

                isConnectionIssue = YES;
                break;
        }
    }


    return isConnectionIssue;
}


#pragma mark - Connection lifecycle management methods

- (BOOL)prepareStreams {

    BOOL streamsPrepared = YES;


    // Check whether stream was prepared and configured before
    if ([self isConfigured] || [self isConnected] || [self isReady]) {

        PNLog(PNLogConnectionLayerErrorLevel, self, @"[CONNECTION::%@] SOCKET AND STREAMS ALREADY CONFIGURATED",
              self.name);
    }
    else {

        UInt32 targetPort = kPNOriginConnectionPort;
        if (self.configuration.shouldUseSecureConnection) {

            targetPort = kPNOriginSSLConnectionPort;
        }

        // Retrieve connection proxy configuration
        [self retrieveSystemProxySettings];


        // Create stream pair on socket which is connected to
        // specified remote host
        CFStreamCreatePairWithSocketToHost(CFAllocatorGetDefault(),
                                           (__bridge CFStringRef)(self.configuration.origin),
                                           targetPort,
                                           &_socketReadStream,
                                           &_socketWriteStream);

        // Configure default socket stream states
        self.writeStreamState = PNSocketStreamNotConfigured;
        self.readStreamState = PNSocketStreamNotConfigured;
        [self configureReadStream:self.socketReadStream];
        [self configureWriteStream:self.socketWriteStream];

        // Check whether stream successfully configured or configuration
        // failed
        if (self.readStreamState != PNSocketStreamReady || self.writeStreamState != PNSocketStreamReady) {

            streamsPrepared = NO;

            [self closeStreams];
        }
    }


    return streamsPrepared;
}

- (void)closeStreams {

    self.closingConnection = YES;

    // Clean up cached data
    [self unscheduleRequestsExecution];
    _proxySettings = nil;


    [self destroyReadStream:self.socketReadStream];
    [self destroyWriteStream:self.socketWriteStream];
}

- (BOOL)connect {

    BOOL isStreamOpened = NO;

    if (![self isConnected] && [self isReady]) {

        if (![self isConnecting]) {

            [self openReadStream:self.socketReadStream];
            [self openWriteStream:self.socketWriteStream];
        }

        isStreamOpened = YES;
    }
    // Looks like streams not ready yet (maybe stream closed
    // during previous session)
    else if (![self isReady] && ![self isConnected]) {

        if (![self isConnecting]) {

            if ([self prepareStreams]) {

                [self connect];
            }
            else {

                [self handleStreamSetupError];
            }
        }
    }


    return isStreamOpened;
}

- (void)reconnect {

    // Marking that connection instance is reconnecting
    // now and after last connection will be closed should
    // automatically renew connection
    self.reconnecting = YES;


    [self destroyReadStream:self.socketReadStream];
    [self destroyWriteStream:self.socketWriteStream];
}

- (void)closeConnection {

    [self closeStreams];


    [self destroyReadStream:self.socketReadStream];
    [self destroyWriteStream:self.socketWriteStream];
}


#pragma mark - Read stream lifecycle management methods

- (void)configureReadStream:(CFReadStreamRef)readStream {

    // Check whether read stream is initial state or not
    if (self.readStreamState != PNSocketStreamNotConfigured) {

        [self destroyReadStream:readStream];
    }


    CFOptionFlags options = (kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable |
            kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered);
    CFStreamClientContext client = [self streamClientContext];

    BOOL isStreamReady = CFReadStreamSetClient(readStream, options, readStreamCallback, &client);
    if (isStreamReady) {

        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        isStreamReady = CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    }

    if (self.streamSecuritySettings != NULL && isStreamReady) {

        // Configuring stream to establish SSL connection
        isStreamReady = CFReadStreamSetProperty(readStream,
                                                (__bridge CFStringRef)NSStreamSocketSecurityLevelKey,
                                                (__bridge CFStringRef)NSStreamSocketSecurityLevelSSLv3);

        if (isStreamReady) {

            // Specify connection security options
            isStreamReady = CFReadStreamSetProperty(readStream,
                                                    kCFStreamPropertySSLSettings,
                                                    self.streamSecuritySettings);
        }
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

    // Destroying input buffer
    _retrievedData = nil;


    if (readStream != NULL) {


        // Unschedule read stream from runloop
        CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamSetClient(readStream, kCFStreamEventNone, NULL, NULL);

        // Checking whether read stream is opened and
        // close it if required
        if (shouldCloseStream) {

            CFReadStreamClose(readStream);
        }

        PNCFRelease(&readStream);
        self.socketReadStream = NULL;


        if (shouldCloseStream) {

            [self handleStreamClose];
        }
    }
}

- (void)openReadStream:(CFReadStreamRef)readStream {

    self.readStreamState = PNSocketStreamConnecting;

    if (!CFReadStreamOpen(readStream)) {

        CFErrorRef error = CFReadStreamCopyError(readStream);
        if (error && CFErrorGetCode(error) != 0) {

            self.readStreamState = PNSocketStreamError;
            [self handleStreamError:error];
        }
        else {

            CFRunLoopRun();
        }

        PNCFRelease(&error);
    }
}


#pragma mark - Read stream lifecycle data processing methods

- (void)readStreamContent {

    if (CFReadStreamHasBytesAvailable(self.socketReadStream)) {

        UInt8 buffer[kPNStreamBufferSize];
        CFIndex readedBytesCount = CFReadStreamRead(self.socketReadStream, buffer, kPNStreamBufferSize);
        if (readedBytesCount > 0) {

            // Check whether working on data deserialization or not
            if (self.deserializer.isDeserializing) {

                // Temporary store data in object
                [self.temporaryRetrievedData appendBytes:buffer length:readedBytesCount];
            }
            else {

                // Store fetched data
                [self.retrievedData appendBytes:buffer length:readedBytesCount];

            }

            [self processResponse];
        }
        // Looks like there is no data or error occurred while tried
        // to read out stream content
        else if (readedBytesCount <= 0) {

            CFErrorRef error = CFReadStreamCopyError(self.socketReadStream);
            [self handleStreamError:error];

            PNCFRelease(&error);
        }
    }
}

- (void)processResponse {

    // Retrieve response objects from server response
    NSArray *responses = [self.deserializer parseResponseData:self.retrievedData];

    if ([responses count] > 0) {

        [responses enumerateObjectsUsingBlock:^(id response, NSUInteger responseIdx, BOOL *responseEnumeratorStop) {

            [self.delegate connection:self didReceiveResponse:response];
        }];
    }


    // Check whether connection stored some response in temporary
    // storage or not
    if ([self.temporaryRetrievedData length] > 0) {

        [self.retrievedData appendData:self.temporaryRetrievedData];
        self.temporaryRetrievedData.length = 0;

        // Try to process retrieved data once more
        // (maybe some full response arrived from remote
        // server)
        [self processResponse];
    }
}


#pragma mark - Write stream lifecycle management methods

- (void)configureWriteStream:(CFWriteStreamRef)writeStream {

    // Check whether write stream is in initial state or not
    if (self.writeStreamState != PNSocketStreamNotConfigured) {

        [self destroyWriteStream:writeStream];
    }

    CFOptionFlags options = (kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes |
            kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered);
    CFStreamClientContext client = [self streamClientContext];
    BOOL isStreamReady = CFWriteStreamSetClient(writeStream, options, writeStreamCallback, &client);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);


    if (isStreamReady) {

        self.writeStreamState = PNSocketStreamReady;


        // Schedule write stream on current runloop
        CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
}

- (void)openWriteStream:(CFWriteStreamRef)writeStream {

    self.writeStreamState = PNSocketStreamConnecting;

    if (!CFWriteStreamOpen(writeStream)) {

        CFErrorRef error = CFWriteStreamCopyError(writeStream);
        if (error && CFErrorGetCode(error) != 0) {

            self.writeStreamState = PNSocketStreamError;
            [self handleStreamError:error];
        }
        else {

            CFRunLoopRun();
        }

        PNCFRelease(&error);
    }
}

- (void)destroyWriteStream:(CFWriteStreamRef)writeStream {

    BOOL shouldCloseStream = self.writeStreamState == PNSocketStreamConnected;
    self.writeStreamState = PNSocketStreamNotConfigured;
    self.writeStreamCanHandleData = NO;

    // Check whether write buffer was currently processed or not
    if (_writeBuffer && [_writeBuffer hasData] &&
        [_writeBuffer isPartialDataSent] && _writeBuffer.isSendingBytes) {

        // Notify delegate about that request processing hasn't been completed
        [self.dataSource connection:self didCancelRequestWithIdentifier:_writeBuffer.requestIdentifier];

        // Clean up
        _writeBuffer = nil;
    }


    if (writeStream != NULL) {

        // Unschedule write stream from runloop
        CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFWriteStreamSetClient(writeStream, kCFStreamEventNone, NULL, NULL);

        // Checking whether write stream is opened and
        // close it if required
        if (shouldCloseStream) {

            CFWriteStreamClose(writeStream);
        }

        PNCFRelease(&writeStream);
        self.socketWriteStream = NULL;

        if (shouldCloseStream) {

            [self handleStreamClose];
        }
    }
}


#pragma mark - Write stream buffer management methods

- (void)prepareNextRequestPacket {

    // Check whether data source can provide some data right after connection is established
    // or not
    if ([self.dataSource hasDataForConnection:self]) {

        NSString *requestIdentifier = [self.dataSource nextRequestIdentifierForConnection:self];
        self.writeBuffer = [self.dataSource connection:self requestDataForIdentifier:requestIdentifier];
    }
}

- (void)writeBufferContent {

    // Check whether write buffer has been received and write stream
    // is ready to accept bytes
    if ([self isConnected] && self.writeBuffer != nil) {

        // Check whether connection can pull some data
        // from write buffer or not
        BOOL isWriteBufferIsEmpty = ![self.writeBuffer hasData];
        if (!isWriteBufferIsEmpty) {

            if (self.isWriteStreamCanHandleData) {

                // Check whether we just started request processing or not
                if (self.writeBuffer.offset == 0) {

                    // Mark that buffer content sending was initiated
                    self.writeBuffer.sendingBytes = YES;

                    // Notify data source that we started request processing
                    [self.dataSource connection:self
                processingRequestWithIdentifier:self.writeBuffer.requestIdentifier];
                }


                // Last chance to check whether connection is in suitable state or not
                // (connection delegates may decide that connection should be reset
                // so connection should avoid from data sending)
                if ([self isConnected] && !self.isReconnecting) {

                    CFIndex bytesWritten = CFWriteStreamWrite(self.socketWriteStream,
                                                              [self.writeBuffer buffer],
                                                              [self.writeBuffer bufferLength]);

                    // Check whether error occurred while tried to
                    // process request
                    if (bytesWritten < 0) {

                        // Mark that buffer content is not processed at this moment
                        self.writeBuffer.sendingBytes = NO;

                        // Retrieve error which occurred while tried to
                        // write buffer into socket
                        CFErrorRef writeError = CFWriteStreamCopyError(self.socketWriteStream);
                        [self handleRequestProcessingError:writeError];

                        PNCFRelease(&writeError);
                    }
                    // Check whether socket was able to transfer whole
                    // write buffer at once or not
                    else if (bytesWritten == self.writeBuffer.length) {

                        // Mark that buffer content is not processed at this moment
                        self.writeBuffer.sendingBytes = NO;

                        // Set readout offset to buffer content length (there is no more
                        // data to send)
                        self.writeBuffer.offset = self.writeBuffer.length;

                        isWriteBufferIsEmpty = YES;
                    }
                    else {

                        // Increase buffer readout offset
                        self.writeBuffer.offset = (self.writeBuffer.offset + bytesWritten);
                        if (self.writeBuffer.offset == self.writeBuffer.length) {

                            isWriteBufferIsEmpty = YES;
                        }
                    }
                }
            }
        }


        if (isWriteBufferIsEmpty) {

            // Retrieving reference on request's identifier who's
            // body has been sent
            NSString *identifier = self.writeBuffer.requestIdentifier;
            self.writeBuffer = nil;

            [self.dataSource connection:self didSendRequestWithIdentifier:identifier];


            // Check whether should try to send next request or not
            if (self.shouldProcessNextRequest) {

                [self scheduleNextRequestExecution];
            }
        }
    }
}


#pragma mark - Handler methods

- (void)handleStreamConnection {

    // Ensure that both read and write streams are connected before notify
    // delegate about successful connection
    if (self.readStreamState == PNSocketStreamConnected && self.writeStreamState == PNSocketStreamConnected) {

        [self.delegate connection:self didConnectToHost:self.configuration.origin];
    }
}

- (void)handleStreamClose {

    // Ensure that both read and write streams reset before notify delegate
    // about connection close event
    if (self.readStreamState == PNSocketStreamNotConfigured && self.writeStreamState == PNSocketStreamNotConfigured) {

        // Checking whether instance is reconnecting or not
        if(self.isReconnecting) {

            self.reconnecting = NO;
            [self connect];
        }
        else {

            [self.delegate connection:self didDisconnectFromHost:self.configuration.origin];
        }
    }
}

- (void)handleReadStreamHasData {

    [self readStreamContent];
}

- (void)handleWriteStreamCanAcceptData {

    self.writeStreamCanHandleData = YES;
    [self writeBufferContent];
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

- (void)handleStreamError:(CFErrorRef)error {

    [self handleStreamError:error shouldCloseConnection:NO];
}

- (void)handleStreamError:(CFErrorRef)error shouldCloseConnection:(BOOL)shouldCloseConnection {

    if (error && CFErrorGetCode(error) != 0) {

        NSString *errorDomain = (__bridge NSString *)CFErrorGetDomain(error);
        PNError *errorObject = [self processStreamError:error];
        BOOL shouldNotifyDelegate = YES;
        BOOL isCriticalStreamError = NO;

        PNLog(PNLogConnectionLayerErrorLevel, self, @"[CONNECTION::%@] GOT ERROR: %@", self.name, errorObject);

        // Check whether error is caused by SSL issues or not
        if ((errorObject.code <= errSSLProtocol && errorObject.code >= errSSLBadCipherSuite) ||
            errorObject.code == errSSLConnectionRefused) {

            // Checking whether user allowed to decrease security options
            // and we can do it
            if (self.configuration.shouldReduceSecurityLevelOnError &&
                self.sslConfigurationLevel == PNConnectionSSLConfigurationStrict) {

                PNLog(PNLogConnectionLayerInfoLevel, self, @"[CONNECTION::%@] REDUCING SSL REQUIREMENTS", self.name);

                shouldNotifyDelegate = NO;

                self.sslConfigurationLevel = PNConnectionSSLConfigurationBarelySecure;

                // Try to reconnect with new SSL security settings
                [self reconnect];
            }
            // Check whether connection can fallback and use plain HTTP connection
            // w/o SSL
            else if (self.configuration.canIgnoreSecureConnectionRequirement &&
                    self.sslConfigurationLevel == PNConnectionSSLConfigurationBarelySecure) {

                PNLog(PNLogConnectionLayerInfoLevel, self, @"[CONNECTION::%@] DISCARD SSL", self.name);

                shouldNotifyDelegate = NO;

                self.sslConfigurationLevel = PNConnectionSSLConfigurationInSecure;

                // Try to reconnect with new SSL security settings
                [self reconnect];
            }
        }
        else if ([errorDomain isEqualToString:(NSString *)kCFErrorDomainPOSIX] ||
                [errorDomain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {

            // Check whether connection should be reconnected
            // because of critical error
            if ([self isConnectionIssuesError:error]) {

                // Mark that we should init streams close because
                // of critical error
                shouldCloseConnection = YES;

                // Mark that further operation is impossible w/o
                // reconnection
                isCriticalStreamError = YES;

            }
        }


        // Check whether error occurred during data sending or not
        if (!isCriticalStreamError && self.writeBuffer && [self.writeBuffer isPartialDataSent]) {

            shouldNotifyDelegate = NO;
            [self handleRequestProcessingError:error];
        }


        if (shouldNotifyDelegate) {

            if (shouldCloseConnection) {

                if (!self.isClosingConnection) {

                    [self.delegate connection:self willDisconnectFromHost:self.configuration.origin withError:errorObject];

                    [self closeStreams];
                }
            }
            else {

                [self.delegate connection:self connectionDidFailToHost:self.configuration.origin withError:errorObject];
            }
        }
    }
}

- (void)handleStreamSetupError {

    // Prepare error message which will be
    // sent to connection channel delegate
    PNError *setupError = [PNError errorWithCode:kPNConnectionErrorOnSetup];

    [self.delegate connection:self connectionDidFailToHost:self.configuration.origin withError:setupError];
}

- (void)handleRequestProcessingError:(CFErrorRef)error {

    if (error && CFErrorGetCode(error) != 0) {

        if (self.writeBuffer && [self.writeBuffer isPartialDataSent]) {

            [self.dataSource connection:self
  didFailToProcessRequestWithIdentifier:self.writeBuffer.requestIdentifier
                              withError:[self processStreamError:error]];
        }
    }
}


#pragma mark - Misc methods

- (CFStreamClientContext)streamClientContext {

    return (CFStreamClientContext){0, (__bridge void *)(self), NULL, NULL, NULL};
}

- (CFMutableDictionaryRef)streamSecuritySettings {

    if (self.configuration.shouldUseSecureConnection && _streamSecuritySettings == NULL &&
            self.sslConfigurationLevel != PNConnectionSSLConfigurationInSecure) {

        // Configure security settings
        _streamSecuritySettings = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 6, NULL, NULL);
        if (self.sslConfigurationLevel == PNConnectionSSLConfigurationStrict) {

            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelSSLv3);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanFalse);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLValidatesCertificateChain, kCFBooleanTrue);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsExpiredRoots, kCFBooleanFalse);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsAnyRoot, kCFBooleanFalse);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLPeerName, kCFNull);
        }
        else {

            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelSSLv3);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanTrue);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsExpiredRoots, kCFBooleanTrue);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
            CFDictionarySetValue(_streamSecuritySettings, kCFStreamSSLPeerName, kCFNull);
        }
    }
    else if (!self.configuration.shouldUseSecureConnection ||
            self.sslConfigurationLevel == PNConnectionSSLConfigurationInSecure) {

        PNCFRelease(&_streamSecuritySettings);
    }


    return _streamSecuritySettings;
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

- (PNError *)processStreamError:(CFErrorRef)error {

    PNError *errorInstance = nil;

    if (error) {

        NSString *errorDomain = (__bridge NSString *)CFErrorGetDomain(error);

        if ([self isConnectionIssuesError:error]) {

            int errorCode = kPNClientConnectionClosedOnInternetFailureError;
            if (self.writeBuffer != nil && [self.writeBuffer hasData] && self.writeBuffer.isSendingBytes) {

                errorCode = kPNRequestExecutionFailedOnInternetFailureError;
            }

            errorInstance = [PNError errorWithCode:errorCode];
        }
        else {

            errorInstance = [PNError errorWithDomain:errorDomain code:CFErrorGetCode(error) userInfo:nil];
        }
    }


    return errorInstance;
}


#pragma mark - Memory management

- (void)dealloc {

    // Closing all streams and free up resources
    // which was allocated for their support
    [self closeConnection];
    _delegate = nil;
    _proxySettings = nil;

    PNCFRelease(&_streamSecuritySettings);
}

#pragma mark -


@end
