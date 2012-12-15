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
    custom_presence: false
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com/presence', pubnub_setup );

// -----------------------------------------------------------------------
// PRESENCE
// -----------------------------------------------------------------------
socket.on( 'join', function(uuid) {
    console.log(uuid, ' -> JOINED!!!');
} );
socket.on( 'leave', function(uuid) {
    console.log(uuid, ' -> LEFT!!!');
} );


// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION
// -----------------------------------------------------------------------
socket.on( 'connect', function() {
    console.log('connected!!!');
} );

})();
