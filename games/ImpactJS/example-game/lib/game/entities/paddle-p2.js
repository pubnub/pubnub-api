ig.module(
	'game.entities.paddle-p2'
)
.requires(
	'game.entities.paddle',
  'plugins.pubnub.game'
)
.defines(function(){

EntityPaddlePlayer2 = EntityPaddle.extend({
	animSheet: new ig.AnimationSheet( 'media/paddle-blue.png', 64, 128 ),
  belongs_to: 'player_2',
});

});
