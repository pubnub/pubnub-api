(function(){

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var pubnub_setup = {
    channel       : 'my_pn_channel',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect(
    'http://pubsub.pubnub.com/example-ns',
    pubnub_setup
);

// -----------------------------------------------------------------------
// RECEIVE A MESSAGE
// -----------------------------------------------------------------------
socket.on( 'message', function(message) {

    // Received a Message!
    alert(JSON.stringify(message));

} );

})();
