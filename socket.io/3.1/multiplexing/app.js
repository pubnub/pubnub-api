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
var socket1 = io.connect( 'http://pubsub.pubnub.com/socket1', pubnub_setup );
var socket2 = io.connect( 'http://pubsub.pubnub.com/socket2', pubnub_setup );
var socket3 = io.connect( 'http://pubsub.pubnub.com/socket3', pubnub_setup );


socket1.on( 'connect', function() {
    console.log( 'i connected on socket1' );
} );
socket2.on( 'connect', function() {
    console.log( 'i connected on socket2' );
} );
socket3.on( 'connect', function() {
    socket2.send('HELLO!O!O!!');
    console.log( 'i connected on socket3' );
} );

socket2.on( 'message', function(message) {
    console.log('socket2:', message);
} );

})();
