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
    custom_presence : false,
    presence : false
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var socket = io.connect( 'http://pubsub.pubnub.com/history', pubnub_setup );


// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION, then publish and get history
// -----------------------------------------------------------------------
socket.on( 'connect', function() {
  console.log('connected!!!');
  
  socket.send( 'this is test data', function(message) { });
  socket.send( 'this is test data 2', function(message) {
    socket.history({'count': 10}, function(response) {
      console.log(response);
    });
  });
});

})();
