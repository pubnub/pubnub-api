ig.module(
	'game.entities.paddle-player'
)
.requires(
	'game.entities.paddle'
)
.defines(function(){

EntityPaddlePlayer = EntityPaddle.extend({
	
	animSheet: new ig.AnimationSheet( 'media/paddle-blue.png', 64, 128 ),
	
	update: function() {
		
		if( ig.input.state('up') ) {
			this.vel.y = -100;
		}
		else if( ig.input.state('down') ) {
			this.vel.y = 100;
		}
		else {
			this.vel.y = 0
		}
		
		this.parent();
	}
});

});
