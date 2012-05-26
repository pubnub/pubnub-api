var num_online = 2;
PUBNUB.events.bind( "got_from_server_message_still_there", respondToPresenceCheck); 

function respondToPresenceCheck() {
  PUBNUB.events.fire("send_message", { "name": "still_here" });
  num_online = 1;
  setTimeout( function() {
    $("#num_online").text(num_online);
  }, 2000);
}

PUBNUB.events.bind( "got_message_still_here", function(message) {
  num_online += 1;
});

PUBNUB.events.bind( "got_from_server_message_status", function(message) {
  num_online = message.data.num_clients;    
  $("#num_online").text(num_online);
});

