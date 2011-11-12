ig.module(
	'game.entities.paddle-p1'
)
.requires(
	'game.entities.paddle',
  'plugins.pubnub.game'
)
.defines(function(){

EntityPaddlePlayer1 = EntityPaddle.extend({

	animSheet: new ig.AnimationSheet( 'media/paddle-red.png', 64, 128 ),
  belongs_to: 'player_1',

});

});
