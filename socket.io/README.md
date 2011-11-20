# EARLY ACCESS - Socket.IO on PubNub

Now you can use Socket.IO with PubNub! Take advangate of the Socket.IO API 
leveraging the Human Perceptive Real-time PubNub Cloud Infrastructure.
We believe Socket.IO is the jQuery of Networking.
Socket.IO is a project that makes WebSockets and realtime possible in
all browsers. It also enhances WebSockets by providing built-in multiplexing,
automatic scalability, automatic JSON encoding/decoding, and
even more with PubNub.

![Socket.IO on Pubnub](http://pubnub.s3.amazonaws.com/assets/socket.io-on-pubnub.png "Socket.IO on Pubnub")

## Enhanced Socket.IO with PubNub

We enhanced Socket.IO with PubNub.
Socket.IO with PubNub does not require a Node.JS backend.
This means your code is more
simple and you have extra time to build your
app rather than fiddling with the back-end server code.
Additionally the JS lib payload has been improved for Mobile apps.

## Simplified Socket.IO API Usage

By default, broadcasting is turned on.  This means when you use
emit() or send() functions, broadcasting to all connections occurs 
except to the connection where the message came from.

## Simplifed Features with Socket.IO on PubNub

+ Enhanced User Tracking Presence Events (join, leave).
+ Counts of Active User Connections.
+ Socket Connection Events (connect, disconnect).
+ Stanford Crypto Library with AES Encryption.
+ Batching of Publishes (Send multiple messages at once).
+ Smart Broadcasting (broadcast with auto-recovery on failure).
+ Acknowledgements of Message Receipt.
+ Multiplexing many channels on one socket.
+ Private Messaging.
+ Server Side Events.
+ Disconnect from a Socket or Namespace.

## How to use

First, include `pubnub.js` and `socket.io.js`:

```html
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js></script>
<script src="socket.io.js"></script>
<script>
  var socket = io.connect('http://localhost');
  socket.on( 'news', function (data) {
    console.log(data);
    socket.emit( 'my-other-event', { my: 'data' } );
  } );
</script>
```

## Short recipes

### Sending and receiving events.

Socket.IO allows you to emit and receive custom events.
Besides `connect`, `message` and `disconnect`, you can emit custom events:

```js
// Use PubNub Setup for Your PubNub Account
var pubnub_setup = {
    channel       : 'my_mobile_app',
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false
};

var socket = io.connect( 'http://pubsub.pubnub.com', pubnub_setup );

socket.on( 'connect', function() {
    console.log('Connection Established! Ready to send/receive data!');
    socket.send('sock');
} );

socket.on( 'message', function(message) {
    console.log(message);
} );

socket.on( 'disconnect', function() {
    console.log('my connection dropped');
} );

socket.on( 'reconnect', function() {
    console.log('my connection has been restored!');
} );

```

### User Presence (Rooms)

Sometimes you want to put certain sockets in the same room, so that it's easy
to broadcast to all of them together.

Think of this as built-in channels for sockets. Sockets `join` and `leave`
rooms in each socket.

```js
var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );
chat.on( 'leave', function(user) {
    console.log('user left');
} );
chat.on( 'join', function(user) {
    console.log('user joined');
} );
```

### Enhanced Presence with User Counts.

```js
// TODO
```

### Using it just as a cross-browser WebSocket

If you just want the WebSocket semantics, you can do that too.
Simply leverage `send` and listen on the `message` event:

```html
<script>
  var socket = io.connect('http://localhost/');
  socket.on('connect', function () {
    socket.send('hi');

    socket.on('message', function (msg) {
      // my msg
    });
  });
</script>
```


### Restricting yourself to a namespace

If you have control over all the messages and events emitted for a particular
application, using the default `/` namespace works.

If you want to leverage 3rd-party code, or produce code to share with others,
socket.io provides a way of namespacing a `socket`.

This has the benefit of `multiplexing` a single connection. Instead of
socket.io using two `WebSocket` connections, it'll use one.

The following example defines a socket that listens on '/chat' and one for
'/news':

```html
<script>
  var chat = io.connect('http://localhost/chat')
    , news = io.connect('http://localhost/news');

  chat.on('connect', function () {
    chat.emit('hi!');
  });

  news.on('news', function () {
    news.emit('woot');
  });
</script>
```

### Getting acknowledgements

Sometimes, you might want to get a callback when the client
confirmed the message reception.

TODO!

```js
  var socket = io.connect(); // TIP: .connect with no args does auto-discovery
  socket.on('connect', function () { // TIP: you can avoid listening on `connect` and listen on events directly too!
    socket.emit('ferret', 'tobi', function (data) {
      console.log(data); // data will be 'woot'
    });
  });
```

## License 

(The MIT License)

Copyright (c) 2011 PubNub Inc.

Copyright (c) 2011 Guillermo Rauch <guillermo@learnboost.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
