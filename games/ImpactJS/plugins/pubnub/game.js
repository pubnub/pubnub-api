ig.module( 
	'plugins.pubnub.game'
)
.requires(
	'plugins.pubnub.lib',
	'impact.game'
)
.defines(function(){

  ig.PubNubGame = ig.Game.extend({

    game_id : "",
    player_id : "",
    game_lobby : "pong_lobby",
    player_notification : "",

    init: function() {
      var game_obj = this;
      var p = PUBNUB;

      // generate a unique player_id
      p.uuid(function(uuid) {
        game_obj.player_id = uuid;
        console.log('generated uuid ' + uuid);

        // listen on that channel
        // this is how the server will send direct messages
        p.subscribe({
          channel  : uuid + "_from_server",
          callback : function(message) { 
            console.log('got_from_server ' + message.type + ' ' + message.id); 
            p.events.fire("got_from_server", message);
          }
        });

        PUBNUB.events.bind("got_from_server", function(message) {
          p.events.fire(message.type, message);
        });

      });

      p.events.bind("still_there", function(message) {
        p.events.fire("send_to_server", {'type':'still_here'});
      });

      p.events.bind("send_to_lobby", function(message) {
        console.log('sent_to_lobby ' + message.type); 
        message.player_id = game_obj.player_id;
        p.publish({
          channel : game_obj.game_lobby,
          message : message 
        });
      });

      p.events.bind("send_to_server", function(message) {
        console.log('sent_to_server ' + message.type + ' ' + message.id); 
        p.publish({
          channel : game_obj.player_id + "_from_client",
          message : message  
        });
      });

      p.events.bind("ent_update", function(message) {
        console.log("ent_update");
        p.events.fire("ent_update_" + message.id, message);
      });

      p.events.bind("ent_now_yours", function(message) {
        console.log("ent_now_yours");
        p.events.fire("ent_now_yours_" + message.id, message);
      });

      p.events.bind("ent_not_yours", function(message) {
        console.log("ent_not_yours");
        p.events.fire("ent_not_yours_" + message.id, message);
      });

    },
  });

});
