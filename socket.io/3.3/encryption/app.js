(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var pubnub_setup = {
    channel       : 'bootstrap-app',
    password      : '*HLSGHUSEHJFIlT#YUTGKJDHKJ',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com/events', pubnub_setup );

// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION
// -----------------------------------------------------------------------
socket.on( 'connect', function() {

    // Connected!!!
    socket.send('SUPER SECRET!!!!!!! EATING BATTERIES');

} );

// -----------------------------------------------------------------------
// RECEIVE A MESSAGE
// -----------------------------------------------------------------------
socket.on( 'message', function(message) {

    // Received a Message!
    console.log(message);
    // i0cz1TAv8dWjsu6F
    // HfhzNsTGrc66OZgEFL4jmjvXC1Zg6J

} );

})();
