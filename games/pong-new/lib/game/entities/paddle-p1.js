ig.module(
	'game.entities.paddle-p1'
)
.requires(
	'game.entities.paddle',
  'plugins.pubnub.game'
)
.defines(function(){

EntityPaddlePlayer1 = EntityPaddle.extend({
	
	animSheet: new ig.AnimationSheet( 'media/paddle-blue.png', 64, 128 ),
  is_local_player: false, 
  last_broadcasted_state: "not_moving",
  last_broadcasted_y: 150,
  player_uuid: "",
  game_uuid: "",

	update: function() {
    		
    if (this.is_local_player) {
      if( ig.input.state('up') ) {
        this.vel.y = -100;
        if (this.last_broadcasted_state != "moving_up") {
          paddle_obj = this;
          PUBNUB.publish({
              channel : "pong",
              message : { "player_uuid": paddle_obj.player_uuid,
                          "game_uuid": paddle_obj.game_uuid,
                          "type": "moving_up", }
          });
          this.last_broadcasted_state = "moving_up";
        }
      }
      else if( ig.input.state('down') ) {
        this.vel.y = 100;
        if (this.last_broadcasted_state != "moving_down") {
          paddle_obj = this;
          PUBNUB.publish({
              channel : "pong",
              message : { "player_uuid": paddle_obj.player_uuid,
                          "game_uuid": paddle_obj.game_uuid,
                          "type": "moving_down", }
          });
          this.last_broadcasted_state = "moving_down";
        }
      }
      else {
        this.vel.y = 0
        if (this.last_broadcasted_state != "not_moving") {
          paddle_obj = this;
          PUBNUB.publish({
              channel : "pong",
              message : { "player_uuid": paddle_obj.player_uuid,
                          "game_uuid": paddle_obj.game_uuid,
                          "pos_y": paddle_obj.pos.y, 
                          "type": "not_moving", }
          });
          this.last_broadcasted_state = "not_moving";
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
