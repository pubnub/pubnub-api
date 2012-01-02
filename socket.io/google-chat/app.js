(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var pubnub_setup = {
    channel       : 'google-chat',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com', pubnub_setup );
var chat   = io.connect( 'http://pubsub.pubnub.com/chat', pubnub_setup );

// -----------------------------------------------------------------------
// SOCKET
// -----------------------------------------------------------------------
socket.on( 'connect', function() {
    console.log('CONNECTED');
} );
socket.on( 'join', function(user) {
    console.log('joined',user.uuid);
} );
socket.on( 'leave', function(user) {
    console.log('leave',user);
} );
socket.on( 'message', function(message) {
    console.log('MESSAGE',message);
} );


// -----------------------------------------------------------------------
// CHAT
// -----------------------------------------------------------------------
chat.on( 'connect', function() {
    console.log('CONNECTED, chat');
} );
chat.on( 'join', function(user) {
    console.log('joined,chat',user.uuid);
} );
chat.on( 'leave', function(user) {
    console.log('leave,chat',user);
} );
chat.on( 'message', function(message) {
    console.log('MESSAGE',chat,message);
} );


// -----------------------------------------------------------------------
// RECEIVE A MESSAGE
// -----------------------------------------------------------------------



})();
