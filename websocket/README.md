# PubNub Websockets

New update! - SEE: [Websocket Client Interface](http://www.pubnub.com/websockets/)

> The following code and docs below are legacy!!!  Make sure to visit the link above.

## WebSocket Client Interface

Optionally PubNub offers you the full RFC 6455
Support for WebSocket Client Specification.
PubNub WebSockets enables any browser (modern or not) to support
the HTML5 WebSocket standard APIs.
Use the WebSocket Client Directly in your Browser that
Now you can use `new WebSocket` any time!

You will need to hit the right resource URLs.
Make sure to follow the examples below.

Here is a quick example providing an easy adapter:

```javascript
WebSocket  = PUBNUB.ws;
var socket = new WebSocket('wss://pubsub.pubnub.com/PUB/SUB/CHANNEL');
```

Alternatively you may directly access the PubNub WebSocket via:

```javascript
var socket = new PUBNUB.ws('wss://pubsub.pubnub.com/PUB/SUB/CHANNEL')
```

The following example opens a `new WebSocket` in
**WSS Secure Socket Mode** with **2048 Bit SSL** Encryption.

```html
<!-- Import PubNub Core Lib -->
<script src="https://pubnub.a.ssl.fastly.net/pubnub.min.js"></script>

<!-- Use WebSocket Constructor for a New Socket Connection -->
<script>(function() {

    /* 'wss://ORIGIN/PUBLISH_KEY/SUBSCRIBE_KEY/CHANNEL' */
    WebSocket  = PUBNUB.ws;
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
<script src="http://pubnub.a.ssl.fastly.net/pubnub.min.js"></script>

<!-- NON-SSL Use WebSocket Constructor for a New Socket Connection -->
<script>(function() {

// Note "ws://" rather than "wss://"
WebSocket  = PUBNUB.ws;
var socket = new WebSocket('ws://pubsub.pubnub.com/demo/demo/my_channel')

})();</script>
```
