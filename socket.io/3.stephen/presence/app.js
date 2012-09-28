(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var my_user_data = { name : "John" };
var pubnub_setup = {
    user          : my_user_data,
    channel       : 'bootstrap-app-presence',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};

setTimeout( function() {
    my_user_data.name = "Sam";
}, 5000 );
// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com/events', pubnub_setup );

// -----------------------------------------------------------------------
// PRESENCE
// -----------------------------------------------------------------------
socket.on( 'join', function(user) {
    console.log(user.data.name, ' -> JOINED!!!');
} );
socket.on( 'leave', function(user) {
    console.log(user.data.name, ' -> LEFT!!!');
} );


// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION
// -----------------------------------------------------------------------
socket.on( 'connect', function() {
    console.log('connected!!!');
} );

// -----------------------------------------------------------------------
// RECEIVE A MESSAGE
// -----------------------------------------------------------------------
socket.on( 'message', function(message) {

    // Received a Message!

} );

window['socket'] = socket;

})();
