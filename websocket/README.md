# PubNub WebSocket Emulation

PubNub offers full RFC 6455 Support for WebSocket Client Specification.
This means you can use the included WebSocket:

```javascript
<!-- Import PubNub Core Lib -->
<script src=https://pubnub.a.ssl.fastly.net/pubnub-3.1.min.js></script>

<!-- Import WebSocket Emulation Lib -->
<script src=websocket.js></script>

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

