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

    init: function() {
      var game_obj = this;
      // generate a unique player_id
      PUBNUB.uuid(function(uuid) {
        game_obj.player_id = uuid;
      });

      
      // define event behavior
      PUBNUB.event = {
        list : {},
        bind : function( name, fun ) {
          (event.list[name] = event.list[name] || []).push(fun);
        },
        fire : function( name, data ) {
          p.each(
            event.list[name] || [],
            function(fun) { fun(data) }
          );
        },
      }

    },

    subscribeToGame: function() {
      var game_obj = this;

      PUBNUB.event.bind("send_" + game_obj.game_id, function(type, data) {
        console.log("send_" + game_obj.game_id + "" + type + "" + data);
        PUBNUB.publish({
          channel : game_obj.game_id,
          message : { "player_id": game_obj.player_id,
                      "type": type, 
                      "data": data }

        });
      });

      PUBNUB.subscribe({
        channel  : game_obj.game_id,
        error    : function() {    
          console.log("connection lost.")
        },
        callback : function(message) { 
          console.log("receive_ " + game_obj.game_id + "" + message);
          PUBNUB.event.fire("receive_" + game_obj.game_id, message);
        }
      });
    }

  });

});
