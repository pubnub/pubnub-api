# PubNub - Real-time Communications
- Publish and Subscribe Always-on Socket Cloud
- One-to-Many / One-to-One / Platform Ubiquitous Cloud
- Globally Distributed Cloud Network - Many Datacenters World-Wide - Fastest Connections
- Optimized for Mobile and Web - iPhone, Android, Chrome, Firefox, IE and more.
- Locksetp Synchronization with Everyone on Earth - Synchronize Mass Audiences.

PubNub is a client-to-client push service in the cloud.
Connect Everything to Everything; literally!
This is a cloud-based service for broadcasting Real-time messages
to millions of web and mobile clients simultaneously.

## PubNub Version 3.1

The current version number for communication with PubNub Cloud is `3.1`.

## Quick Links

- Twitter: http://twitter.com/PubNub
- Website: http://www.pubnub.com
- Videos: http://www.youtube.com/playlist?p=PLF0BA2B6DAAF4FBBF
- Socket.IO: https://github.com/pubnub/pubnub-api/tree/master/socket.io
- Showcase: http://www.pubnub.com/blog
- Interview: http://techzinglive.com/?p=227

## PubNub is Optimized for MOBILE and WEB

- Earth Scale Deployment - Your App scales with ease.
- Many Datacenters World Wide - High Performance everywhere on Earth.
- Optimized for Slow and Fast Connections - Fast for mobile 3G, WiFi, 4G and Edge.
- Reliable Message Delivery on Unreliable connections.
- Compression and Bundling - Faster than WebSockets - up to 100msg per second faster.
- PHP, Ruby, JavaScript and more - All Streamlined Platforms Supported.
- The API FAST! - iPhone, Android and Blackberry phones zip!
- It's a Breeze for Mobile Phones - Quick and Easy Development.
- Mass Broadcasting Replication - Send a message to Millions of People in Milliseconds.
- Platform Ubiquitous Cloud - Every Platform Now has a way to communicate Instantly.
- Cross Device Communication - Androids and iPhones and Browsers -- all connected.

# PubNub API Specification

Use this section of the README to review the current specification for
PubNub Cloud Client Libraries.
The pseudocode will guide you in learning how each
client library must act in order to properly support the
breadth of features powered by PubNub Cloud.
Most client libraries are already written!
So go check out the list of libraries already available.

# Rules of PubNub Client Lib

- Must be able to communicate with EVERY other PubNub Client Lib.
- Must be Non-blocking (Asynchronous) on all I/O.
- Must use single Dictionary/Object as Parameter for all methods.
- Must follow guides in this README file including method param patterns.
- Includes a Full Unit Test with a test of each method.
- Includes Quick Usage Doc with Example Copy/Paste Code for each Method.
- The Lib must be only ONE file. (i.e. pubnub.py, Pubnub.java, Pubnub.cs)
- Okay to include Vendor Files.

<a id="import"/>
## IMPORT LIBS

There are support libs that are needed in order to provide
full implementation of a PubNub Client API.
Here is a list of all needed external imports
common to most platforms and programming languages.

- Crypto AES - Client Side Encryption/Decryption
- TLS/SSL 2048bit Support or Better
- HMAC and SHA256 Hash-Lib
- Async HTTP/HTTPS or Async TCP Sockets (Non-Blocking)
- JSON Encode/Decode or Stringify/Parse
- ZLib for GZIP
- UUID for Unique ID Generation
- URL Encode
- Events Fire/Bind/Unbind

## Public Methods 

- init()
- time()
- uuid()
- publish()
- subscribe()
- unsubscribe()
- history()

### INIT()

Create a new PubNub Entity for Publishing/Subscribing.
This entity associates itself with account-level credentials
and a selected origin.
Also Security Options are Specified.

```javascript
var pubnub = PubNub.init({
    publish_key   : "CUSTOMER_PUBLISH_KEY",
    subscribe_key : "CUSTOMER_SUBSCRIBE_KEY",
    secret_key    : "CUSTOMER_SECRET_KEY",
    ssl           : true,
    cipher_key    : "AES-Crypto-Cipher-Key",
    origin        : "pubsub.pubnub.com"
})
```

### TIME()

This function is a utility only and has not functional
value other than a PING to the PubNub Cloud.

```javascript
PubNub.time(function(time){
    log(time)
})
```

### UUID()

Utility function for generating a UUID.

```javascript
PubNub.uuid(function(uuid){
    log(uuid)
})
```

### PUBLISH()

Broadcast a message on a specific channel.
The message may be any valid JSON value including:

1. Dictionary (Objects).  ```{"msg":"hi"}```
2. Arrays.                ```[1,2,3,4]```
3. Strings.               ```"Hello!"```
4. Numbers.               ```123456```

```javascript
PubNub.publish({
    channel  : "hello_world",
    message  : "Hi.",
    callback : function(response) { log(response) }
})
```

### SUBSCRIBE()

Listen for messages on a specified channel.
Register events for receiving messages, connecting,
disconnecting and reconnecting after an unintended disconnect.

```javascript
PubNub.subscribe({
    channel    : "my-channel",
    callback   : function(message) { log(message) },
    connect    : function() { log("Connected") },
    disconnect : function() { log("Disconnected") },
    reconnect  : function() { log("Reconnected") }
})
```

### UNSUBSCRIBE()

Stop Listen for messages on a specified channel.

```javascript
PubNub.unsubscribe({
    channel : "my-channel"
})
```

### HISTORY()

Retrieve past messages sent through the system.

```javascript
PubNub.history({
    channel  : "my-channel",
    limit    : 100,
    callback : (messages) { log(messages) }
})
```

## Cryptography Guide

##### PubNub Cryptography in JavaScript

[PubNub Crypto](http://pubnub.github.com/pubnub-api/crypto/index.html)
demonstrates with PubNub Cryptography for sensitive data.
Use this page and source code to provide high
levels of security for data intended to be private
and unreadable.

The Cipher Key specifies the particular transformation
of plaintext into ciphertext, or vice versa during decryption.
The Cipher Key exchange must occur on an external system
outside of PubNub in order to maintain secrecy of the key.

Make use of the design patterns shown here when implementing a
PubNub Client Library.  However you must follow directly
the Interface shown in this Doc when utilizing
AES Encryption.
Search for `cipher\_key` to find interface guide.

http://pubnub.github.com/pubnub-api/crypto/index.html

## Connection Pooling Guide for APIs

As a rule of performance, an always-on socket connection
pre-established will provide faster message delivery
and receipt.
Establishing a socket pool is simple when using
socket loop libraries such as `Ruby::EventMachine`
or `C LibEvent`.
The following Pseudocode will guide you when
create a socket connection pool:

```python
def create_socket_pool():
    current_socket = -1
    max_sockets    = 10

    for connection_number in range(max_sockets):
        socket_pool.append(Socket('pubsub.pubnub.com'))

    def next_socket():
        current_socket += 1
        if current_socket >= max_sockets: current_socket = -1
        return socket_pool[current_socket]

    return next_socket

next_socket = create_socket_pool()

next_socket() ## Get Next Socket.
```

## Documentation Rules

 - Must fit into a single page README.md file.
 - Must be inside README.md within the API directory.
 - May not be more than one file.

## API Directory Structure Rules

 - Must be simple to start with copy/paste easy.
 - Include all required vendor libs in sub-directories.

## HTTPS TLS SSL 2048bit Encryption

HTTPS is recommended for the highest level of security for
REST requests to PubNub. Using REST over HTTPS is not required. 
However for secure communication, you should make sure the client or
REST toolkit you're using is configured to use SSL.
The PubNub Cloud service will continue to support both HTTP and HTTPS.

## Message Signing Guide with HMAC/SHA256

In order to provide Origin Authenticity and High Level of Security,
Secret Key
When accessing Amazon SimpleDB using one of the AWS SDKs, the SDK handles the authentication process for you. For a list of available AWS SDKs supporting Amazon SimpleDB, see Available Libraries.

However, when accessing Amazon SimpleDB using a REST request, you must provide the following items so the request can be authenticated.

## REST Interface

##### HTTP HEADERS

Include these *required* headers with each reqeust to the
PubNub HTTP REST interface.
Exclude all other headers where possible.

```
V: Version-Number
User-Agent: NAME-OF-THE-CLIENT-INTERFACE

```
##### Example Headers:

```
V: 3.1
User-Agent: PHP
```

##### FULL HTTP Request Example:

```
GET /time/0 HTTP/1.1
V: 3.1
User-Agent: Ruby
```

There are may possible `User-Agent`'s.
The following is an accepted style format
for the value of `User-Agent` header:

- PHP
- JavaScript
- Node.JS
- Ruby
- Ruby-Rhomobile
- Python
- Python-Twisted
- Python-Tornado
- C-LibEV
- C-LibEvent
- C-Qt
- VB
- C#
- Java
- Java-Android
- Erlang
- Titanium
- Corona
- C-Arduino
- C-Unity
- C#-Mono
- Lua
- Obj-C-iOS
- C#-WP7
- Cocoa
- Perl5
- Perl6
- Go-Google
- Bash
- Haskell

### TIME()

##### URL Params:

```
/time/0
```

##### Request Example: 

```
GET /time/0 HTTP/1.1
```

##### Response: 

```javascript
[7529152783414]
```

### SUBSCRIBE()

This is a special HTTP Request that holds the connection
and response until a message is published or the connection timer
fires a timetoken update.

##### The Subscribe Process Lifecycle 

1. Send First Request.
2. Receive a snazzy new TimeToken.
3. Send Second Request with Last Received new snazzy TimeToken.
4. Receive a response after X Minutes with array of Messages (may be empty) and new TimeToken.
5. Repeat #2-#5 forever until UNSUBSCRIBE()

##### URL Params:

```
/subscribe/subscribe_key/channel/0/timetoken
```

##### First Request: 

```
GET /subscribe/demo/my-channel/0/0 HTTP/1.1
```

##### First Response: 

```javascript
[[],"7529152783414"]
```

##### Second Request: 

```
GET /subscribe/demo/my-channel/0/7529152783414 HTTP/1.1
```

##### Response When Message Published: 

```javascript
[[MSG,MSG,MSG],"75291527861853"]
```

##### Response when Timer Update Fires with New TimeToken

```javascript
[[],"75291527861853"]
```

### PUBLISH()

##### URL Params:

```
/publish/pub-key/sub-key/sha256-signature/channel/0/json
```

##### Request Example: 

```
GET /publish/demo/demo/e0991b12871de57b333fd0c992f7d3112577cf62/my-channel/0/{"msg":"hi"} HTTP/1.1
```

##### Response: 

```javascript
[1,"D"]
```

##### Response Codes:

The Publish Response always returns success transmission details.
The First element of the response Array is a bool value either `0` or `1`.
`0` means failure and `1` means successful transmission.
If the response code is `0`, then the transmission has failed.
In the condition of a failed transmission, an explanation is provided
in the second element of the response array.

##### Successful Transmission: 

```javascript
[1,"D"]
```

##### Failed Transmission: 

```javascript
[0,"Reason for Failure Shown Here"]
```

##### Possible Failure Reasons:

- "Disconnected" - The network has gone away.
- "Message Too Big" - Max message size exceeded.
- "Invalid Publish Key" - Wrong Publish Key was Used.
- "Invalid Message Signature" - The message was SHA256 Signed incorrectly.


### HISTORY()

History API will allow you to fetch previously published messages.
Currently you can only fetch the last 100 messages.
However soon-to-come features will include forever-history fetching.

##### URL Format:

```
/history/sub-key/channel/0/limit
```

##### Request Example: 

```
GET /history/demo/my-channel/0/100 HTTP/1.1
```

##### Response: 

```javascript
[MSG,MSG,MSG]
```

## Asynchronous Mandate

All functions are required to be non-blocking.
All I/O must be Asynchronous.
Threads are `okay` however *SOCKET LOOPS* are much preferred.
Examples of Good Socket Loop libs are:

- Twisted (Python)
- Tornado (Python)
- Node.JS (JavaScript)
- Event::Machine (Ruby)
- LibEvent (C)
- LibEV (C)
- Any::Event (Perl)
- POE::Async (Perl)

Any executed function must not stop the execution stack.
If a return value is needed from a function call,
then a callback function is required to be a parameter
of the function -- and the return value is supplied to the callback.

## Pseudocode Logic Requirements

Publish and Subscribe require significant amounts of checks
in order to provide for easy use to the developer using the API.
Show as follows are the Publish and Subscribe functions which
have basic Pseudocode Logic Requirements:

### PUBLISH()

```python
def publish( self, args ) :
    ## Fail if bad input.
    if not (args['channel'] and args['message']) :
        print('Missing Channel or Message')
        return False

    ## Capture User Input
    channel = args['channel']

    if self.cipher_key:
        message = json.dumps(EncodeAES( self.cipher_key, args['message'] ))
    else :
        message = json.dumps(args['message'])

    ## Capture Callback
    if args.has_key('callback') :
        callback = args['callback']
    else :
        callback = lambda x : x

    ## Sign Message
    if self.secret_key :
        signature = hmac.new( self.secret_key, '/'.join([
            self.publish_key,
            self.subscribe_key,
            channel,
            message
        ]), hashlib.sha256 ).hexdigest()
    else :
        signature = '0'

    ## Send Message
    self._request([
        'publish',
        self.publish_key,
        self.subscribe_key,
        signature,
        URL_ENCODE(channel),
        '0',
        URL_ENCODE(message)
    ], callback )
```

### SUBSCRIBE()

```python
def subscribe( self, args ) :
    ## Fail if missing channel
    if not 'channel' in args :
        print('Missing Channel.')
        return False

    ## Fail if missing callback
    if not 'callback' in args :
        print('Missing Callback.')
        return False

    ## Capture User Input
    channel      = URL_ENCODE(args['channel'])
    callback     = args['callback']
    connectcb    = args['connect'] or lambda x:x
    disconnectcb = args['disconnect'] or lambda x:x
    reconnectcb  = args['reconnect'] or lambda x:x

    if 'errorback' in args:
        errorback = args['errorback']
    else:
        errorback = lambda x: x

    ## New Channel?
    if not (channel in self.subscriptions) :
        self.subscriptions[channel] = {
            'first'        : False,
            'connected'    : 0,
            'disconnected' : 0,
            'timetoken'    : '0'
        }

    ## Ensure Single Connection
    if self.subscriptions[channel]['connected'] :
        print("Already Connected")
        return False

    self.subscriptions[channel]['connected'] = 1

    ## Subscription TimeStack 
    def receive():
        ## STOP CONNECTION?
        if not self.subscriptions[channel]['connected']:
            return

        def sub_callback(response):
            ## STOP CONNECTION?
            if not self.subscriptions[channel]['connected']:
                return

            ## CONNECTED CALLBACK
            if not self.subscriptions[channel]['first'] :
                self.subscriptions[channel]['first'] = True
                connectcb()

            ## PROBLEM?
            if not response:
                ## Disconnect
                if not self.subscriptions[channel]['disconnected']:
                    self.subscriptions[channel]['disconnected'] = 1
                    disconnectcb()

                def time_callback(_time):
                    if not _time:
                        reactor.callLater(time.time()+1, receive)
                        return errorback("Lost Network Connection")
                    else:
                        reactor.callLater(time.time()+1, receive)

                ## ENSURE CONNECTED (Call Time Function)
                return self.time({ 'callback' : time_callback })
            else:
                ## Reconnect
                if self.subscriptions[channel]['disconnected']:
                    self.subscriptions[channel]['disconnected'] = 0
                    reconnectcb()

            self.subscriptions[channel]['timetoken'] = response[1]
            reactor.callLater(time.time()+0.0001, receive)

            for message in response[0]:
                if self.cipher_key:
                    callback(json.loads(DecodeAES( self.cipher_key, message )))
                else:
                    callback(json.loads(message))

        ## CONNECT TO PUBNUB SUBSCRIBE SERVERS
        try :
            self.subscriptions[channel]['request'] = self._request( [
                'subscribe',
                self.subscribe_key,
                channel,
                '0',
                str(self.subscriptions[channel]['timetoken'])
            ], sub_callback )
        except :
            reactor.callLater(time.time()+1, receive)
            return

    ## BEGIN SUBSCRIPTION (LISTEN FOR MESSAGES)
    receive()
```

### UNSUBSCRIBE()

```python
def unsubscribe( self, args ):
    channel = args['channel']

    ## IGNORE IF NOT CONNECTED
    if not (channel in self.subscriptions):
        return False

    ## ABORT CONNECTION
    self.subscriptions[channel]['request'].abort()

    ## DISCONNECT
    self.subscriptions[channel]['disconnected'] = 0
    self.subscriptions[channel]['connected']    = 0
    self.subscriptions[channel]['timetoken']    = 0
    self.subscriptions[channel]['first']        = False
```
