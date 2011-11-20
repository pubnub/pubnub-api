# EARLY ACCESS - Socket.IO on PubNub

Now you can use Socket.IO with PubNub! Take advangate of the Socket.IO API 
leveraging the Human Perceptive Real-time PubNub Cloud Infrastructure.
We believe Socket.IO can be considered the jQuery of Networking.
Socket.IO is a project that makes WebSockets and realtime possible in
all browsers. It also enhances WebSockets by providing built-in multiplexing,
automatic scalability, automatic JSON encoding/decoding, and more.

## Enhanced PubNub Version

Note this version of Socket.IO is enhanced and
does not require a Node.JS backend.
This means your code is even more
simple and you have 2x extra time to build your
app rather than fiddling with the back-end server code.
Additionally the JS lib payload has been reduced to less than 5KB.

## Simplified API Usage

By default, broadcasting is turned on.  This means when you use
emit() or send() functions, broadcasting to all connections occurs 
except to the connection where the message came from.

## Added/Simplifed Features in PubNub Version of Socket.IO

Enhanced User Tracking Presence Events (join, part)
Counts of Active User Connections.
Socket Connection Events (connect, disconnect)
Stanford Crypto Library with AES Encryption.
Batching of Publishes (Send multiple publishes at once).
Smart Broadcasting (broadcast with auto-recovery on failure).
Multiplexing many channels on 1 socket.
Private Messaging.
Server Side Events.
Disconnect From a Socket.

## How to use

First, include `pubnub.js` and `socket.io`:

```js
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js></script>
<script src=http://cdn.pubnub.com/socket.io.min.js></script>
```


... VVVVVVVVVVVVVVVV

    var socket = io.connect('http://localhost');
    on
        connection-established
        connection-lost

        joined
        part

        private message customer
        public message
    emit - ME
        'channel', {data}
    send - sends on global channel
        {data}
    broadcast - no.... just make it do the same thing.

... ^^^^^^^^^^^^^^^^


```html
<script src="socket.io.js"></script>
<script>
  var socket = io.connect('http://localhost');
  socket.on( 'news', function (data) {
    console.log(data);
    socket.emit( 'my other event', { my: 'data' } );
  } );
</script>
```

For more thorough examples, look at the `examples/` directory.

## Short recipes

### Sending and receiving events.

Socket.IO allows you to emit and receive custom events.
Besides `connect`, `message` and `disconnect`, you can emit custom events:

```js
// note, io.listen(<port>) will create a http server for you
var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {
  io.sockets.emit('this', { will: 'be received by everyone' });

  socket.on('private message', function (from, msg) {
    console.log('I received a private message by ', from, ' saying ', msg);
  });

  socket.on('disconnect', function () {
    io.sockets.emit('user disconnected');
  });
});
```

### Storing data associated to a client

Sometimes it's necessary to store data associated with a client that's
necessary for the duration of the session.

#### Server side

```js
var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {
  socket.on('set nickname', function (name) {
    socket.set('nickname', name, function () { socket.emit('ready'); });
  });

  socket.on('msg', function () {
    socket.get('nickname', function (err, name) {
      console.log('Chat message by ', name);
    });
  });
});
```

#### Client side

```html
<script>
  var socket = io.connect('http://localhost');

  socket.on('connect', function () {
    socket.emit('set nickname', confirm('What is your nickname?'));
    socket.on('ready', function () {
      console.log('Connected !');
      socket.emit('msg', confirm('What is your message?'));
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

#### Server side

NEED TO SHOW HOW TO DO THIS ...
```js
var io = require('socket.io').listen(80);

var chat = io
  .of('/chat');
  .on('connection', function (socket) {
    socket.emit('a message', { that: 'only', '/chat': 'will get' });
    chat.emit('a message', { everyone: 'in', '/chat': 'will get' });
  });

var news = io
  .of('/news');
  .on('connection', function (socket) {
    socket.emit('item', { news: 'item' });
  });
```

#### Client side:

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

To do this, simply pass a function as the last parameter of `.send` or `.emit`.
What's more, when you use `.emit`, the acknowledgement is done by you, which
means you can also pass data along:

#### Server side

```js
var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {
  socket.on('ferret', function (name, fn) {
    fn('woot');
  });
});
```

#### Client side

```html
<script>
  var socket = io.connect(); // TIP: .connect with no args does auto-discovery
  socket.on('connect', function () { // TIP: you can avoid listening on `connect` and listen on events directly too!
    socket.emit('ferret', 'tobi', function (data) {
      console.log(data); // data will be 'woot'
    });
  });
</script>
```

### Broadcasting messages

To broadcast, simply add a `broadcast` flag to `emit` and `send` method calls.
Broadcasting means sending a message to everyone else except for the socket
that starts it.

#### Server side

```js
var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {
  socket.broadcast.emit('user connected');
  socket.broadcast.json.send({ a: 'message' });
});
```

### Rooms

Sometimes you want to put certain sockets in the same room, so that it's easy
to broadcast to all of them together.

Think of this as built-in channels for sockets. Sockets `join` and `leave`
rooms in each socket.

#### Server side

```js
var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {
  socket.join('justin bieber fans');
  socket.broadcast.to('justin bieber fans').emit('new fan');
  io.sockets.in('rammstein fans').emit('new non-fan');
});
```

### Using it just as a cross-browser WebSocket

If you just want the WebSocket semantics, you can do that too.
Simply leverage `send` and listen on the `message` event:

#### Server side

```js
var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {
  socket.on('message', function () { });
  socket.on('disconnect', function () { });
});
```

#### Client side

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

## License 

(The MIT License)

Copyright (c) 2011 PubNub Inc.

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
