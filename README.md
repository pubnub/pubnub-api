# PubNub - Real-time Communications
- Publish and Subscribe Always-on Socket Cloud
- One-to-Many / One-to-One / Platform Ubiquitous Cloud
- Globally Distributed Cloud Network - Many Datacenters World-Wide - Fastest Connections
- Optimized for Mobile and Web - iPhone, Android, Chrome, Firefox, IE and more.

PubNub is a client-to-client push service in the cloud.
Connect Everything to Everything; literlally!
This is a cloud-based service for broadcasting Real-time messages
to millions of web and mobile clients simultaneously.

## Quick Links

- Twitter: http://twitter.com/PubNub
- Website: http://www.pubnub.com
- Videos: http://www.youtube.com/playlist?p=PLF0BA2B6DAAF4FBBF
- Socket.IO: https://github.com/pubnub/pubnub-api/tree/master/socket.io
- Showcase: http://www.pubnub.com/blog
- Interview: http://techzinglive.com/?p=227

## PubNub is OPTIMIZED for MOBILE and WEB

- Earth Scale Deployment - Your App scales with ease.
- Many Datacenters World Wide - High Performance everywhere on Earth.
- Optimized for Slow and Fast Connections - Reliable Message Delivery on UnReliable connections.
- Compression and Bundling - Faster than WebSockets - up to 100 messges per second vs. 1 msg/sec.
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

## IMPORT

There are support libs that are needed in order to provide
full implementation of a PubNub Client API.
Here is a list of all needed external imports
common to most platforms and programming languages.

- Crypto Standford AES
- TLS/SSL 2048bit Support or Better
- JSON Encode/Decode or Stringify/Parse
- Async HTTP/HTTPS or Async TCP Sockets
- Event System
- HashLib for SHA256
- ZLib for GZIP
- UUID for Universally Unique ID
- URL Encode

## Public Methods 

- init()
- time()
- uuid()
- publish()
- subscribe()
- unsubscribe()
- history()

## REST Interface

### TIME()

#### URL Params:

```
/time/0
```

#### Request Example: 

```http
GET /time/0 HTTP/1.1
```

#### Response: 

```javascript
[7529152783414]
```

### SUBSCRIBE()

This is a special HTTP Request that holds the connection
and response until a message is published or the connection timer
fires a timetoken update.

#### The Subscribe Process Lifecycle 

1. Send First Request.
2. Receive a snazzy new TimeToken.
3. Send Second Request with Last Received new snazzy TimeToken.
4. Receive a response after X Minutes with array of Messages (may be empty) and new TimeToken.
5. Repeat #2-#5 forever until UNSUBSCRIBE()

#### URL Params:

```
/subscribe/subscribe_key/channel/0/timetoken
```

#### First Request: 

```http
GET /subscribe/demo/my-channel/0/0 HTTP/1.1
```

#### First Response: 

```javascript
[[],"7529152783414"]
```

#### Second Request: 

```http
GET /subscribe/demo/my-channel/0/7529152783414 HTTP/1.1
```

#### Response When Message Published: 

```javascript
[[MSG,MSG,MSG],"75291527861853"]
```

#### Response when Timer Update Fires with New TimeToken

```javascript
[[],"75291527861853"]
```

### PUBLISH()

#### URL Params:

```
/publish/pub-key/sub-key/sha256-signature/channel/0/json
```

#### Request Example: 

```http
GET /publish/demo/demo/e0991b12871de57b333fd0c992f7d3112577cf62/my-channel/0/{"msg":"hi"} HTTP/1.1
```

#### Response: 

```javascript
[1,"D"]
```

#### Response Codes:

The Publish Response always returns success transmission details.
The First element of the response Array is a bool value either `0` or `1`.
`0` means failure and `1` means successful trasmission.
If the response code is `0`, then the transmission has failed.
In the condition of a failed transmission, an explanation is provided
in the second element of the response array.

#### Successful Transmission: 

```javascript
[1,"D"]
```

#### Failed Transmission: 

```javascript
[0,"Reason Here"]
```

#### Possible Failure Reasons:

- "Disconnected" - The network has gone away.
- "Message Too Big" - Max message size exceeded.
- "Invalid Publish Key" - Wrong Publish Key was Used.
- "Invalid Message Signature" - The message was SHA256 Signed incorrectly.


### HISTORY()

History API will allow you to fetch previously published messages.
Currently you can only fetch the last 100 messages.
However soon-to-come features will include forever-history fetching.

#### URL Format:

```
/history/sub-key/channel/0/limit
```

#### Request Example: 

```http
GET /history/demo/my-channel/0/100 HTTP/1.1
```

#### Response: 

```javascript
[MSG,MSG,MSG]
```

## Asynchronous Mandate

All functions are required to be non-blocking.
All I/O must be Asynchronous.
Threads are `okay` however *SOCKET LOOPS* are much prefered.
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
then a callback function is required to be a paramater
of the function -- and the return value is supplied to the callback.

### INIT()

```javascript
var pubnub = PubNub.init({
    publish_key   : "CUSTOMER_PUBLISH_KEY",
    subscribe_key : "CUSTOMER_SUBSCRIBE_KEY",
    secret_key    : "CUSTOMER_SECRET_KEY",
    ssl           : true,
    origin        : "pubsub.pubnub.com"
})
```

### TIME()

This function is a utility only and has not functional
value other than a PING to the PubNub Cloud.

```javascript
PubNub.time(function(time){
    console.log(time);
})
```

## Pseudocode



