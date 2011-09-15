ig.module(
	'game.entities.paddle'
)
.requires(
	'plugins.pubnub.entity'
)
.defines(function(){

EntityPaddle = ig.PubNubEntity.extend({
	
	size: {x:64, y:128},
	collides: ig.Entity.COLLIDES.FIXED,
	
	animSheet: new ig.AnimationSheet( 'media/paddle-red.png', 64, 128 ),
	
  is_local_player: false, 
  last_broadcasted_state: "not_moving",
  last_broadcasted_y: 150,

	init: function( x, y, settings ) {
		this.parent( x, y, settings );
		
		this.addAnim( 'idle', 1, [0] );
	},

  move: function(direction, vel) {
    this.vel.y = vel;
    if (this.last_broadcasted_state != direction) {
      paddle_obj = this;
      PUBNUB.publish({
          channel : "pong_" + ig.game.game_uuid,
          message : { "player_uuid": ig.game.player_uuid,
                      "game_uuid": ig.game.game_uuid,
                      "pos_y": paddle_obj.pos.y, 
                      "type": direction, }
      });
      this.last_broadcasted_state = direction;

    }
  },

	update: function() {
    var paddle_obj = this;
    		
    if (this.is_local_player) {
      if( ig.input.state('up') ) {
        if (ig.game.is_host) { 
          setTimeout( function() {
            paddle_obj.move("moving_up", -100);
          }, ig.game.opponent_latency);
        }
        else {
          paddle_obj.move("moving_up", -100);
        }
          

      }
      else if( ig.input.state('down') ) {
        if (ig.game.is_host) { 
          setTimeout( function() {
            paddle_obj.move("moving_down", 100);
          }, ig.game.opponent_latency);
        }
        else {
          paddle_obj.move("moving_down", 100);
        }
      }
      else {
        if (ig.game.is_host) { 
          setTimeout( function() {
            paddle_obj.move("not_moving", 0);
          }, ig.game.opponent_latency);
        }
        else {
          paddle_obj.move("not_moving", 0);
        }
      }
    }
    else {
      switch (this.last_broadcasted_state) {
        case "moving_up":
          this.vel.y = -100
          break;
        case "moving_down":
          this.vel.y = 100
          break;
        case "not_moving":
          this.vel.y = 0
          this.pos.y = this.last_broadcasted_y;
          break;
      }
    }
		this.parent();
	}
});

});

