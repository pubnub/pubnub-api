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

	init: function( x, y, settings ) {
		this.parent( x, y, settings );
		
		this.addAnim( 'idle', 1, [0] );
	},

	update: function() {
    var paddle_obj = this;
    		
    if (ig.game.game_status == 'in_game') {
      if (ig.game.which_player == paddle_obj.belongs_to) {
        if( ig.input.state('up') ) {
          paddle_obj.vel.y = -100;
        }
        else if( ig.input.state('down') ) {
          paddle_obj.vel.y = 100;
        }
        else {
          paddle_obj.vel.y = 0;
        }
      }
    }
		this.parent();
	}
});

});

