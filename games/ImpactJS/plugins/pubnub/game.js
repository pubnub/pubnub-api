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
    game_status : "not_in_game",
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

        p.events.bind("got_from_server", function(message) {
          switch (message.type) {
            case "in_queue":
              console.log("in_queue");  
              break;

            case "game_found":
              console.log("game_found");  
              game_obj.which_player = message.which_player;
              game_obj.getPuck().startMoving();
              game_obj.game_status = "in_game";
              if (game_obj.which_player == "player_1") {
                game_obj.getPaddle2().keepUpdated();
              }
              else {
                game_obj.getPaddle1().keepUpdated();
              }
              game_obj.getPuck().keepUpdated();
              break;

            case "still_there":
              p.events.fire("send_to_server", {'type':'still_here'});
              break;

            case "opponent_left":
              console.log('opponent left');
              break;

            case "you_win":
              game_obj.player_notification = 'You win!';
              game_obj.getPuck().stopMoving(); 
              break;

            case "you_lose":
              game_obj.player_notification = 'You lose!';
              game_obj.getPuck().stopMoving(); 
              break;

            case "game_not_active":
              break;
          }
        });
        
        setTimeout( function() {
          p.events.fire("send_to_lobby", {'type':'looking_for_game'}); 
        }, 2000);

      });

      p.events.bind("send_to_lobby", function(message) {
        console.log('sent_to_lobby ' + message.type + ' ' + message.id); 
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

    },

  });

});
