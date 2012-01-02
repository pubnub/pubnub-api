(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var pubnub_setup = {
    channel       : 'bootstrap-app',
    publish_key   : 'demo',
    password      : 'MauahHahahahahh',
    subscribe_key : 'demo'
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com/events', pubnub_setup );
var socket2 = io.connect( 'http://pubsub.pubnub.com/events2', pubnub_setup );

// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION
// -----------------------------------------------------------------------
socket.on( 'connect', function() {

    // Connected!!!
    socket.send('ENCRYPTED MESSAGE?????', function(info) {
        alert(JSON.stringify(info));
    } );

} );

// -----------------------------------------------------------------------
// RECEIVE A MESSAGE
// -----------------------------------------------------------------------
socket.on( 'message', function(message) {
    alert(message);
} );

// -----------------------------------------------------------------------
// RECEIVE A MESSAGE on SOCKET 2 (Really the same Socket)
// -----------------------------------------------------------------------
socket2.on( 'connect', function() {
    socket2.send('ENCRYPTED MESSAGE22222 222 2 2 2 2 ');
} );
socket2.on( 'message', function(message) {
    alert('REALLY SOCKET #2 but is same socket.' + message);
} );


})();
