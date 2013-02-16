# YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

## PubNub 3.4.1 Real-time Cloud Push API - JAVASCRIPT
http://www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/tutorial/javascript-push-api

The PubNub Network is a blazingly fast Global Messaging Service for building
real-time web and mobile apps. Thousands of apps and developers
rely on PubNub for delivering human-perceptive real-time
experiences that scale to millions of users worldwide. PubNub delivers
the infrastructure needed to build amazing Mobile, MMO games, social apps,
business collaborative solutions, and more.

## SIMPLE EXAMPLE
```html
<div id=pubnub pub-key=demo sub-key=demo></div>
<script src=http://cdn.pubnub.com/pubnub-3.4.1.min.js ></script>
<script>

    // LISTEN
    PUBNUB.subscribe({
        channel : "hello_world",
        message : function(m){ alert(m) }
    })

    // SEND
    PUBNUB.publish({
        channel : "hello_world",
        message : "Hi."
    })

</script>
```

## ADVANCED STYLE
```html
<div id=pubnub pub-key=demo sub-key=demo></div>
<script src=http://pubnub.s3.amazonaws.com/pubnub-3.4.1.min.js ></script>
<script>(function(){
    PUBNUB.subscribe({
        channel    : "hello_world",        // CONNECT TO THIS CHANNEL.
        restore    : false,                // FETCH MISSED MESSAGES ON PAGE CHANGES.
        message    : function(message) {}, // RECEIVED A MESSAGE.
        presence   : function(message) {}, // OTHER USERS JOIN/LEFT CHANNEL.
        connect    : function() {},        // CONNECTION ESTABLISHED.
        disconnect : function() {},        // LOST CONNECTION (OFFLINE).
        reconnect  : function() {}         // CONNECTION BACK ONLINE!
    })
})();
</script>
```

## HISTORY AND HERE-NOW EXAMPLE
```html
<span onclick="hereNow()">Click Me for Here Now!</span>
<span onclick="history()">Click Me for History!</span>

<script>(function(){
    function hereNow() {
        PUBNUB.here_now({
            channel  : 'hello_world',
            callback : function (message) { console.log(message) }
        });
    }

    function history() {
        PUBNUB.history({
            count    : 10,
            channel  : 'hello_world',
            callback : function (message) { console.log(message) }
        });
    }
})();</script>
```

## SSL MODE
```html
<div id=pubnub ssl=on></div>
<script src=https://pubnub.a.ssl.fastly.net/pubnub-3.4.1.min.js></script>
<script>(function(){

    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo',
        origin        : 'pubsub.pubnub.com',
        ssl           : true
    });

    pubnub.subscribe({
        channel  : 'my_channel',
        connect  : function() { /* ... */ },
        callback : function(message) {
            alert(JSON.stringify(message));
        }
    });

})();</script>
```

## HISTORY
```html
<div id=pubnub></div>
<script src=http://pubnub.a.ssl.fastly.net/pubnub-3.4.1.min.js></script>
<script>(function(){

    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo'
    });

    pubnub.history({
        count    : 10,
        channel  : 'hello_world',
        callback : function (message) { console.log(message) }
    });

})();</script>
```


## REPLAY

Replay is an API that allows you to "replay" the events of a channel
as they happened before in the past.
Replay will repeat the message delivery sequence in sync with
the timeline as they occured.

>**NOTE:** You must have Storage/Playback enabled on your Account.

```html
<div id=pubnub></div>
<script src=http://pubnub.a.ssl.fastly.net/pubnub-3.4.1.min.js></script>
<script>(function(){

/* GENERATE CHANNEL */
var channel = PUBNUB.uuid()
,   pub_key = 'demo'
,   sub_key = 'demo'
,   out     = PUBNUB.$('pubnub-terminal-out')
,   p       = PUBNUB.init({ subscribe_key : 'demo', publish_key : 'demo' });

/* OPEN RECEIVE SOCKET */
p.subscribe({
    channel : channel,
    message : function(data) { console.log(data) },
    connect : start_replay
});

/* START THE MOVIE STREAM */
function start_replay() {
    p.replay({
        source      : 'my_channel',
        destination : channel,
        reverse     : true
    });
}

})();</script>
```

## WebSocket Client Interface

Optionally PubNub offers you the full RFC 6455
Support for WebSocket Client Specification.
PubNub WebSockets enables any browser (modern or not) to support
the HTML5 WebSocket standard APIs.
Use the WebSocket Client Directly in your Browser that
Now you can use `new WebSocket` any time!

You will need to hit the right resource URLs.
Make sure to follow the examples below.

Here is a quick example:

```javascript
var socket = new WebSocket('wss://pubsub.pubnub.com/PUB/SUB/CHANNEL')
```

The following example opens a `new WebSocket` in
**WSS Secure Socket Mode** with **2048 Bit SSL** Encryption.

```html
<!-- Import PubNub Core Lib -->
<script src="https://pubnub.a.ssl.fastly.net/pubnub-3.4.1.min.js"></script>

<!-- Use WebSocket Constructor for a New Socket Connection -->
<script>(function() {

    "use strict"

    /* 'wss://ORIGIN/PUBLISH_KEY/SUBSCRIBE_KEY/CHANNEL' */
    var socket = new WebSocket('wss://pubsub.pubnub.com/demo/demo/my_channel')

    // On Message Receive
    socket.onmessage = function(evt) {
        console.log('socket receive');
        console.log(evt.data);
    }

    // On Socket Close
    socket.onclose = function() {
        console.log('socket closed');
    }

    // On Error
    socket.onerror = function() {
        console.log('socket error');
    }

    // On Connection Establish
    socket.onopen = function(evt) {
        console.log('socket open');

        // Send a Message!
        socket.send('hello world!');
    }

    // On Send Complete
    socket.onsend = function(evt) {
        console.log('socket send');
        console.log(evt);
    }

    console.log(socket)

})();</script>
```

#### To Disable SSL WSS Secure Sockets:

```html
<!-- NON-SSL Import PubNub Core Lib -->
<script src="http://pubnub.a.ssl.fastly.net/pubnub-3.4.1.min.js"></script>

<!-- NON-SSL Use WebSocket Constructor for a New Socket Connection -->
<script>(function() {

// Note "ws://" rather than "wss://"
var socket = new WebSocket('ws://pubsub.pubnub.com/demo/demo/my_channel')

})();</script>
```

## Using the PUBNUB init() Function

How to create a new instance of the PubNub Object directly in JavaScript.
To do this, simply follow this `init` example:

```html
<script src=http://cdn.pubnub.com/pubnub-3.4.1.min.js ></script>
<script>(function(){

    // INIT PubNub
    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo',
        origin        : 'pubsub.pubnub.com',
        uuid          : 'myCustomUUID'
    })

    // LISTEN
    pubnub.subscribe({
        channel : "hello_world",
        message : function(m){ alert(m) }
    })
 
    // SEND
    pubnub.publish({
        channel : "hello_world",
        message : "Hi."
    })

})();</script>
```

>**NOTE:** You do not need to use the `<div id=pubnub>` DIV with this method!

## Using with AES256 Encryption

This client now supports AES256 encryption out of the box!
And its super-easy to use! Check out the
file `encrypted_chat_demo.html` for a working example of
using encryption between JavaScript and other PubNub clients.

##### Important Highlights

Be sure to include the following JavaScript Files:
1. pubnub.js, 
2. gibberish, and 
3. encryption adapter:

```html
<script src="http://cdn.pubnub.com/pubnub-3.4.1.min.js"></script>
<script src="crypto/gibberish-aes.js"></script>
<script src="crypto/encrypt-pubnub.js"></script>
```

2. When instantiating your PubNub instance object,
use the .secure method instead of the .init method:

```javascript
var cipher_key = "enigma";
var secure_pubnub = PUBNUB.secure({
    publish_key   : "demo",
    subscribe_key : "demo",
    cipher_key    : cipher_key
});
```

That's pretty much it.
Use subscribe, publish, and history as you would normally,
only the implementation is different,
being that the message traffic is now encrypted.

## SUPER ADVANCED SETTINGS

#### WINDOWING AND MESSAGE ORDERING

>**NOTE:** Windowing is in favor of battery savings
and throughput. The effect is more bundled messages
better compression and faster response times.
Windowing is a good idea most of the time.

PubNub JavaScript library includes a `windowing` feature that will
automatically allow the PubNub Network the window time needed
to bundle, compress and optimize messages for high-throughput.
This means that if you specify a long window, you will be able to
receive significant performance improvements and optimized performance.
With high throughput applications 
(Apps that send many messages per second)
a long enough window will benefit in performance and will allow
the needed period for the PubNub Network
to order the message delivery and compress the response efficiently.

>**NOTE:** Windowing 1000ms will allow 100 messages
in a second to be bundled and compressed at optimal speeds.

```javascript
var pubnub = PUBNUB.init({
    windowing     : 1000,    // MILLISECONDS
    publish_key   : 'demo',
    subscribe_key : 'demo'
});
```

Windowing is a good idea! Please use it for improved network efficiency.

#### KEEPALIVE

>**NOTE:** The JavaScript library will automatically detect disconnects
in near real-time regardless of `keepalaive`.

There exists extra rare cases where `keepalives` are used
to detect disconnections of the network connection;
situations where a network cable was unplugged for example.
Optionally you may sacrafice bandwidth and reduce battery life
by lowering the `keepalive` value.
By reducing the `keepalive` you receive
greater precision to detect rare edge-case drops.
The Default `keepalive` is *60 seconds*.
**Reducing this value to 30 seconds will help detect 
only the rare edge-case network problems
sooner under rare network disruption situations.**
It is not a good idea to reduce this value lower.
If you need it lower more, you must contact PubNub first.
Again, the JavaScript library will automatically
detect disconnects in near real-time anyway,
so it is not necessary to reduce this value further.

```javascript
var pubnub = PUBNUB.init({
    keepalive     : 30,
    publish_key   : 'demo',
    subscribe_key : 'demo'
});
```

## BEST PRACTICES

#### MESSAGE DELIVERY vs. GUARANTEED MESSAGE DELIVERY

The PubNub Network is a high throughput and reliable messaging service.
Note however that PubNub is not a guaranteed delivery with full Read Receipt Transactions.
You can however use improved designs and best practices to ensure you increase reliability.
One method includes *High Windowing Length* which provides slight improvements.

>**NOTE:** Higher windowing lengths allow improved message delivery.

We recommend following a few best practices to achieve high frequency of message delivery.
First ensure you are checking the publish response code and re-sending 
the publish if an error code is returned.

There is an easy way to make sure you do not run into undelivered
messages due to high frequency of published.
Actually there are a few easy ways.
The first option is to make sure you don't publish too quickly.
Do this by limiting to one concurrent publish per channel.
This is achievable by waiting for the publish response before sending another message.

Use our Elastic Message options.
You should instead send a single large message rather than segment
messages into small packets you manually assemble them on the receiving client.

>**NOTE:** Turn on Elastic Message Sizes in your Customer Account: 
https://admin.pubnub.com/

Is it possible to ensure 100% messages are delivered?  **YES!**
The way to do this includes a Read Receipt Design Pattern.
You must allow the Receiver of a message to ACKNOWLEDGE that
a message was successfully received.
The Sender will continuously re-send the message; with a delay between each re-send.
This continues until an ACKNOWLEDGEMENT is received from the receiver.
