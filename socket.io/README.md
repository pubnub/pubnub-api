# Socket.IO on PubNub

Get a faster Socket.IO with PubNub! Take advantage of the Socket.IO API 
leveraging Human Perceptive Real-time on PubNub Infrastructure.
We believe Socket.IO is the jQuery of Networking.
Socket.IO is a project that makes WebSockets and Real-time possible in
all browsers. It also enhances WebSockets by providing built-in multiplexing,
automatic scalability, automatic JSON encoding/decoding, and
even more with PubNub.

## Enhanced Socket.IO with PubNub

![Socket.IO on PubNub](http://pubnub.s3.amazonaws.com/assets/socket.io-enhanced-with-pubnub.png "Socket.IO on PubNub")

We enhanced Socket.IO with PubNub.
Faster JavaScript, Smaller Footprint, Faster Cloud Network and 
Socket.IO with PubNub does not require a Node.JS backend.
This means your code is lean and 
simple giving you extra time to build your app.
The updated JS payload has been optimized for Mobile Apps;
which means excellent performance for laptops too.

## SOCKET.IO VIMEO CHANNEL

+ [Socket.IO Vimeo Channel](https://vimeo.com/channels/291682)
## VIDEO TUTORIALS

+ ./presence/ - [Presence Tutorial.](http://vimeo.com/pubnub/socket-io-pubnub-user-presence)
+ ./bootstrap-mobile/ - [Bootstrap for Mobile iPhone/Android Apps.](http://vimeo.com/pubnub/socket-io-pubnub-get-started-with-a-bootstrap)
+ ./bootstrap-web/ - [Bootstrap for Desktop/Tablet Web Apps.](http://vimeo.com/pubnub/socket-io-pubnub-get-started-with-a-bootstrap)
+ ./unit-test/ - [Unit Test for Socket.IO on PubNub.](http://vimeo.com/pubnub/socket-io-pubnub-unit-test)
+ ./simple-button/ - [Simple Button App for learning PubNub.](http://vimeo.com/pubnub/socket-io-pubnub-simple-button)
+ ./multiplexing/ - [Multiplexing Tutorial.](http://vimeo.com/pubnub/socket-io-pubnub-socket-multiplexing)
+ ./encryption/ - [Encryption Tutorial.](http://vimeo.com/pubnub/socket-io-on-pubnub-encryption)
+ ./acknowledgements/ - [Acknowledgements Tutorial.](http://vimeo.com/pubnub/socket-io-pubnub-acknowledgement-of-message-receipt)

## BACKGROUND VIDEO

+ [Origin of Socket.IO on PubNub](http://vimeo.com/pubnub/socket-io-pubnub-origin-of-socket-io)

## Simplified Socket.IO API Usage

By default, all messages are broadcast.  This means when you use
emit() or send() functions, the message will be broadcast.

## New and Simplifed Features with Socket.IO on PubNub

+ Full Security Mode with SSL at 2048bit by PubNub.
+ Enhanced User Tracking Presence Events (join, leave).
+ Disable Presence (join, leave).
+ Get Counts of Active Users per Connection.
+ Get a List of Active Users.
+ Customer User Data.
+ Socket level Events (connect, disconnect, reconnect).
+ Multiplexing many channels on one socket.
+ Multiple Event Binding on one socket.
+ Smart Broadcasting (broadcast with auto-recovery on failure).
+ Disconnect from a Channel.
+ Acknowledgements of Message Receipt.
+ Stanford Crypto Library with AES Encryption.
+ Server Side Events.
+ Geo Data with Latitude/Longitude.

## How to use

First, include `pubnub.js` and `socket.io.js`:

```html
<script src="http://cdn.pubnub.com/socket.io.min.js"></script>
<script>
  var socket = io.connect('http://pubsub.pubnub.com');
  socket.on( 'news', function (data) {
    console.log(data);
  } );
</script>
```

This simplified usage of Socket.IO will create a connection, listen for a 
`news` event and log the data to the console.

## Short recipes

### Sending and receiving events.

Socket.IO allows you to emit and receive custom events.
Reserved Events are: `connect`, `message`, `disconnect`,
`reconnect`, `ping`, `join` and `leave`.

```js
// IMPORTANT: PubNub Setup with Account
var pubnub_setup = {
    channel       : 'my_mobile_app',
    publish_key   : 'demo',
    subscribe_key : 'demo'
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

>NOTE: You must enable presence on your PubNub account before this feature is available!  Contact your Account Representative. 

Sometimes you want to put certain sockets in the same room, so that it's easy
to broadcast to all of them together.

Think of this as built-in channels for sockets. Sockets `join` and `leave`
rooms in each channel.

```js
var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );
chat.on( 'leave', function(user) {
    console.log( 'user left', user );
} );
chat.on( 'join', function(user) {
    console.log( 'user joined', user );
} );
```
### Disable User Presence (Room Events: join, leave)

Maybe you do not need to spend the extra message consumption rates of
Sending/Receiving messages for User Join/Leave events.  If this is the case,
you will want to disable presenece detection.  This saves you a lot of messages.

```js
var pubnub_setup = {
    channel       : 'my_mobile_app',
    presence      : false, // DISABLE PRESENCE HERE
    publish_key   : 'demo',
    subscribe_key : 'demo'
};
var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );
```


### Custom User Presence (Custom User Data)

Optionally you may need to supply specific details
about a user who has connected
or disconnected recently, or ongoign during usage of the app.
This is because you have a database with user details in a table
like MongoDB, CouchDB, MySQL, Redis or another.
And you want to share these details over the wire
on Join/Leave events with other connected users.
The best way to relay custom user details is to
use this following sample code:

```js
var MY_USER_DATA = { name : "John" };
var pubnub_setup = {
    user          : MY_USER_DATA,
    channel       : 'my_mobile_app',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};
var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );
chat.on( 'leave', function(user) {
    // Print and User Data from Other Users
    console.log( 'user left', user.data );
} );
chat.on( 'join', function(user) {
    // Print and User Data from Other Users
    console.log( 'user joined', user.data );
} );

// Change User Details after 5 Seconds
// All Connected users will receive the update.
setTimeout( function() {
    MY_USER_DATA.name = "Sam";
}, 5000 );
```

### Enabling SSL

Enabling security is important, right?
Get started easily by following these four steps:

1. Add On-Page DIV `<div id=pubnub ssl=on></div>`.
2. Point to HTTPS Script `https://dh15atwfs066y.cloudfront.net/socket.io.min.js`.
3. Set `ssl : true` in `pubnub_setup` var.
4. Set HTTPS `https://` in `io.connect()` function.

```html
<!-- 1.) ENABLE SECURE CONNECTIONS FOR THIS PAGE -->
<div id=pubnub ssl=on></div>

<!-- 2.) Use PubNub CDN HTTPS URL -->
<script src=https://dh15atwfs066y.cloudfront.net/socket.io.min.js></script>

<script>(function(){

var pubnub_setup = {
    channel       : 'my_mobile_app',
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : true     // 3.) Set SSL to true
};

// 4.) Set Transport to HTTPS
var chat = io.connect( 'https://pubsub.pubnub.com/chat', pubnub_setup );

chat.on( 'join', function(user) {
    console.log( 'user joined:', user );
} );
chat.on( 'leave', function(user) {
    console.log( 'user left:', user );
} );

})();</script>
```

### User Geo Data with Latitude/Longitude

Do you need Geographical Coordinate Data from which your users are
communicating from?

```js
var pubnub_setup = {
    channel       : 'my_mobile_app',
    publish_key   : 'demo',
    subscribe_key : 'demo',
    geo           : true     //   <--- Geo Flag!!!
};

var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );

chat.on( 'join', function(user) {
    console.log( 'user joined from:', user.geo );
} );
chat.on( 'leave', function(user) {
    console.log( 'user left from:', user.geo );
} );
```

If a user joins after a group has already formed,
a `join` event will be fired for each user already connected.

### Enhanced Presence with User Counts & Lists.

Often you will want to know how many users are connected to a channel (room).
To get this information you simply access the `get_user_count()` function.

```js
var chat = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );
chat.on( 'leave', function(user) {
    console.log(
        'User left. There are %d user(s) remaining.',
        chat.get_user_count(),
        chat.get_user_list()
    );
} );
chat.on( 'join', function(user) {
    console.log(
        'User joined! There are %d user(s) online.',
        chat.get_user_count(),
        chat.get_user_list()
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
<script src="http://cdn.pubnub.com/socket.io.min.js"></script>
<script>
    // Include a Password in the PubNub Setup Object.
    var pubnub_setup = {
        channel       : 'my_mobile_app',
        publish_key   : 'demo',
        subscribe_key : 'demo',
        password      : 'MY-PASSWORD'  // Encrypt with Password
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
from PubNub import PubNub

## Create a PubNub Object
pubnub = PubNub( 'demo', 'demo', None, False )

## Publish To Socket.IO
pubnub.publish({
    'channel' : 'my_pn_channel',
    'message' : {
        "name" : "message",                  ## Event Name
        "ns"   : "example-ns-my_pn_channel", ## Namespace
        "data" : { "my" : "data" }           ## Your Message
    }
})

```

The `Python` code above will send a message to your Socket.IO clients.
Make sure that the client is connected first.

```js
// Use PubNub Setup for Your PubNub Account
var pubnub_setup = {
    channel       : 'my_pn_channel',
    publish_key   : 'demo',
    subscribe_key : 'demo'
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

## Revisions (REV)

#### Security Patch Upgrade (Namespacing)

A security patch was applied to the `namespacing` properties of PubNub
Socket.IO provding an improved separation between channel names and
multiplexed connectivity.  This upgrade made a fundamental change to the
`namespacing` scheme that will require an upgrade to your server side logic.
For updated details, see [Server Sent Events](#sending-events-from-a-server).

Also review a dedicated example of sending data into Socket.IO from the
standard PubNub libraries or the HTTP REST API -
[Non-Socket.IO Communication](https://github.com/pubnub/pubnub-api/tree/master/socket.io/non-socket-io-communication)

## License 

(The MIT License)

Copyright (c) 2011 PubNub Inc.

Copyright (c) 2011 Guillermo Rauch <guillermo@learnboost.com>

![Socket.IO on PubNub](http://pubnub.s3.amazonaws.com/assets/socket.io-on-pubnub-2.png "Socket.IO on PubNub")

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

