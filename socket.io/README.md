# EARLY ACCESS - Socket.IO on PubNub

Get a faster Socket.IO with PubNub! Take advangate of the Socket.IO API 
leveraging Human Perceptive Real-time on PubNub Infrastructure.
We believe Socket.IO is the jQuery of Networking.
Socket.IO is a project that makes WebSockets and Real-time possible in
all browsers. It also enhances WebSockets by providing built-in multiplexing,
automatic scalability, automatic JSON encoding/decoding, and
even more with PubNub.

## Enhanced Socket.IO with PubNub

![Socket.IO on Pubnub](http://pubnub.s3.amazonaws.com/assets/socket.io-enhanced-with-pubnub.png "Socket.IO on Pubnub")

We enhanced Socket.IO with PubNub.
Faster JavaScript, Smaller Footprint, Faster Cloud Network and 
Socket.IO with PubNub does not require a Node.JS backend.
This means your code is lean and 
simple giving you extra time to build your app.
The updated JS payload has been optimized for Mobile Apps;
which means excellent performance for laptops too.

## Simplified Socket.IO API Usage

By default, all messages are broadcast.  This means when you use
emit() or send() functions, the message will be broadcast.

## New and Simplifed Features with Socket.IO on PubNub

+ Enhanced User Tracking Presence Events (join, leave).
+ Get Counts of Active Users per Connection.
+ Socket level Events (connect, disconnect, reconnect).
+ Multiplexing many channels on one socket.
+ Smart Broadcasting (broadcast with auto-recovery on failure).
+ Disconnect from a Channel.
+ Acknowledgements of Message Receipt.
+ Stanford Crypto Library with AES Encryption.
+ Server Side Events.
+ Geo Data with Latitude/Longitude. [beta]
+ Guaranteed Message Delivered Events. [comming soon]
+ Batching of Publishes (Send multiple messages at once). [comming soon]
+ Private Messaging. [comming soon]

## How to use

First, include `pubnub.js` and `socket.io.js`:

```html
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js></script>
<script src="socket.io.js"></script>
<script>
  var socket = io.connect('http://pubsub.pubnub.com');
  socket.on( 'news', function (data) {
    console.log(data);
  } );
</script>
```

This simplified usage of Socket.IO will create a connection, listen for a 
`news` event and log the data to the console.

![Socket.IO on Pubnub - Terminal](http://pubnub.s3.amazonaws.com/assets/pubnub-socket.io-terminal.png "Socket.IO on Pubnub - Terminal")

## Short recipes

### Sending and receiving events.

Socket.IO allows you to emit and receive custom events.
Reserved Events are: `connect`, `message`, `disconnect`,
`reconnect`, `join` and `leave`.

```js
// IMPORTANT: PubNub Setup with Account
var pubnub_setup = {
    channel       : 'my_mobile_app',
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false
};

var socket = io.connect( 'http://pubsub.pubnub.com', pubnub_setup );

socket.on( 'connect', function() {
    console.log('Connection Established! Ready to send/receive data!');
    socket.send('my message here');
    socket.send(1234567);
    socket.send([1,2,3,4,5]);
    socket.send({ apples : 'bananas' });
} );

socket.on( 'message', function(message) {
    console.log(message);
} );

socket.on( 'disconnect', function() {
    console.log('my connection dropped');
} );

// Extra event in Socket.IO provided by PubNub
socket.on( 'reconnect', function() {
    console.log('my connection has been restored!');
} );
```

### User Presence (Room Events: join, leave)

Sometimes you want to put certain sockets in the same room, so that it's easy
to broadcast to all of them together.

Think of this as built-in channels for sockets. Sockets `join` and `leave`
rooms in each channel.

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

Often you will want to know how many users are connected to a channel (room).
To get this information you simply access the `get_user_count()` function.

```js
var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );
chat.on( 'leave', function(user) {
    console.log(
        'User left. There are %d user(s) remaining.',
        chat.get_user_count()
    );
} );
chat.on( 'join', function(user) {
    console.log(
        'User joined! There are %d user(s) online.',
        chat.get_user_count()
    );
} );
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
  var chat = io.connect('http://pubsub.pubnub.com/chat')
    , news = io.connect('http://pubsub.pubnub.com/news');

  chat.on('connect', function () {
    chat.emit('hi!');
  });

  news.on('news', function () {
    news.emit('woot');
  });
</script>
```

### Stanford Encryption AES

To keep super secret messages private, you can use the `password` feature
of Socket.IO on PubNub.  You will be able to encrypt and decrypt 
automatically `client side`.  This means all data transmitted is encrypted
and unreadable to everyone without the correct password.

It is simply to have data encrypted and automatically decrypt on receipt.
Simply add the `password` entry in the `pubnub_setup` object.

IMPORTANT: you must include the `cyrpto.js` library!

```html
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js></script>
<script src=crypto.js></script>
<script src=socket.io.js></script>
<script>
    // Include a Password in the PubNub Setup Object.
    var pubnub_setup = {
        channel       : 'my_mobile_app',
        publish_key   : 'demo',
        subscribe_key : 'demo',
        password      : 'MY-PASSWORD',  // Encrypt with Password
        ssl           : false
    };

    // Setup Encrypted Channel
    var encrypted = io.connect(
        'http://pubsub.pubnub.com/secret',
        pubnub_setup
    );

    // Listen for Connection Ready
    encrypted.on( 'connect', function() {
        // Send an Encrypted Messsage
        encrypted.send({ my_secure_data : 'Super Secret!' });
    } );

    // Receive Encrypted Messages
    encrypted.on( 'message', function(message) {
        // Print Decrypted Data
        console.log(message.my_secure_data);
    } );
</script>
```

This feature will automatically encrypt and decrypt messages
using the Stanford JavaScript Crypto Library with AES.
You can mix `encrypted` and `unencrypted` channels with the
channel multiplexing feature by excluding a password from the
`pubnub_setup` object when setting up a new connection.

NOTE: If a password doesn't match, then the message will *not* be received.
Make sure authorized users have the correct password!

### Using it just as a cross-browser WebSocket

If you just want the WebSocket semantics, you can do that too.
Simply leverage `send` and listen on the `message` event:

```html
<script>
  var socket = io.connect('http://pubsub.pubnub.com/');
  socket.on('connect', function () {
    socket.send('hi');

    socket.on('message', function (msg) {
      // my msg
    });
  });
</script>
```

### Getting Acknowledgements (Receipt Confirmation)

Sometimes, you might want to get a callback when the message was sent
with success status. Note that this does not confirm that the message
was recieved by other clients.  This only acknowledges that the message
was received by the PubNub Cloud.

```js
  var socket = io.connect(); // TIP: auto-discovery
  socket.on( 'connect', function () {
    socket.emit( 'important-message', { data : 1234 }, function (receipt) {
      // Message Delivered Successfully!
      console.log(receipt);
    });
  });
```

### Sending Events from a Server

This example shows you how to send events to your Socket.IO clients
using other PubNub libraries.  We are using the simple syntax of `Python`
here for the example:

```python
from Pubnub import Pubnub

## Create a PubNub Object
pubnub = Pubnub( 'demo', 'demo', None, False )

## Publish To Socket.IO
pubnub.publish({
    'channel' : 'leaf-wrap',
    'message' : {
        'name' : 'message',     ## emit( 'event-name', ... )
        'ns'   : 'chat',        ## chat, news, feed, etc.
        'data' : {'msg':'Hi'}   ## object to be received.
    }
})
```

The `Python` code above will send a message to your Socket.IO clients.
Make sure that the client is connected first.

```js
// Use PubNub Setup for Your PubNub Account
var pubnub_setup = {
    channel       : 'leaf-wrap',
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false
};

var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );

chat.on( 'connect', function(message) {
    console.log('ready to receive messages...');
} );

chat.on( 'message', function(message) {
    // Received Message from Server!
    console.log(message);
} );
```

When you combine the `JavaScript` Socket.IO example with `Python`, you
have the  ablity to send messages to the client directly from your web server 
or terminal!

## License 

(The MIT License)

Copyright (c) 2011 PubNub Inc.

Copyright (c) 2011 Guillermo Rauch <guillermo@learnboost.com>

![Socket.IO on Pubnub](http://pubnub.s3.amazonaws.com/assets/socket.io-on-pubnub-2.png "Socket.IO on Pubnub")

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

