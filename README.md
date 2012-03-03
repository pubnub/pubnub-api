# PubNub - Simple Real-time Communications API
## Publish and Subscribe / One-to-Many / One-to-One / Platform Ubiquitous Cloud

PubNub is a client-to-client push service in the cloud.
Connect Everything to Everything.
This is a cloud-based service for broadcasting Real-time messages
to millions of web and mobile clients simultaneously.

## Additional Links

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

Use this section of the README to see the current specification for
PubNub Client Libraries.
The following pseudocode will guide you in learning how each
client library must act in order to properly support the
breadth of features powered by PubNub Cloud.
Most client libraries are already written!
So go check out the list of libraries already available.

## IMPORT

- Crypto Standford AES
- TLS/SSL 2048bit Support or Better
- JSON Encode/Decode Stringify/Parse
- Async HTTP/HTTPS or Async TCP Sockets
- Event System
- ZLib for GZIP
- UUID
- URL Encode

## Public Methods 

- init()
- time()
- uuid()
- publish()
- subscribe()
- unsubscribe()
- history()
- updater()
- 
- 


## COMET/BOSH over HTTP REST

### TIME()

URL Format:

```
/time/0
```

Request Example: 

```http
GET /time/0 HTTP/1.1
```

Response: 

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

#### URL Format:

```
GET /subscribe/subscribe_key/channel/0/timetoken HTTP/1.1
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

URL Format:

```
/history/sub-key/channel/callback/limit
```


 * /publish/pub-key/sub-key/signature/channel/callback/"msg"
 * /publish/pub-key/sub-key/signature/channel/callback/{"msg":"hi"}
 * /publish/pub-key/sub-key/signature/channel/callback/123

Request Example: 

```http
GET /time/0 HTTP/1.1
```

Response: 

```javascript
[7529152783414]
```

### HISTORY()

URL Format:

```
/history/sub-key/channel/callback/limit
```

Request Example: 

```http
GET /time/0 HTTP/1.1
```

Response: 

```javascript
[7529152783414]
```


## Function Paramater Definitions 

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



