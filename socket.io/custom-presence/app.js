(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var my_user_data = { name : "John" };
var pubnub_setup = {
    user          : my_user_data,
    channel       : 'bootstrap-app',
    publish_key   : 'demo',
    subscribe_key : 'demo',
    presence      : false
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
socket.on( 'custom_join', function(user) {
    console.log(user.data.name, ' -> JOINED!!!');
} );
socket.on( 'custom_leave', function(user) {
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
  console.log("APP got message : " + message);
} );


})();
