(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var pubnub_setup = {
    channel       : 'bootstrap-app',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com/events', pubnub_setup );

// -----------------------------------------------------------------------
// PRESENCE
// -----------------------------------------------------------------------
socket.on( 'join', function(user) {
    console.log('USER JOINED!!!');
} );
socket.on( 'leave', function(user) {
    console.log('USER GONE AWAY!!!');
} );

// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION
// -----------------------------------------------------------------------
socket.on( 'connect', function() {
} );

// -----------------------------------------------------------------------
// RECEIVE A MESSAGE
// -----------------------------------------------------------------------
socket.on( 'message', function(message) {

    // Received a Message!

} );

})();
