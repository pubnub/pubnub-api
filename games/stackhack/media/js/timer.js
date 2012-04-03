var wipe_in;

function addLeadingZero(n) {
  if(n.toString().length < 2) {
    return '0' + n;
  } else {
    return n;
  }
}

// initial load
if ($(document).data("time_til_wipe") != undefined) {
  wipe_in = (+new Date) + $(document).data("time_til_wipe");
}

PUBNUB.events.bind( "got_from_server_message_status", function(message) {
  wipe_in = (+new Date) + message.data.time_til_wipe;
});

PUBNUB.events.bind( "got_from_server_message_mini_status", function(message) {
  wipe_in = (+new Date) + message.data.time_til_wipe;
});

PUBNUB.events.bind( "got_from_server_message_wipe", function(message) {
  wipe_in = (+new Date) + message.data.next;
});

setInterval( function() {
  var now = new Date();
  var time_til_wipe = wipe_in - now;
  updateWipeTimer(time_til_wipe);
  if ((wipe_in == undefined) || (time_til_wipe < 0)) { 
    $("#server_on").hide();
    $("#server_off").show();
  }
  else { 
    $("#server_on").show();
    $("#server_off").hide();
  }
}, 1000);

function updateWipeTimer(time_til_wipe) {
  $("#wipe_m").text(addLeadingZero(Math.floor(time_til_wipe / 60000) % 60000)); 
  $("#wipe_s").text(addLeadingZero(Math.floor(time_til_wipe / 1000) % 60)); 
}

