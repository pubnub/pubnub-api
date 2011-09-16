ig.module(
	'game.entities.paddle-p2'
)
.requires(
	'game.entities.paddle',
  'plugins.pubnub.game'
)
.defines(function(){

EntityPaddlePlayer2 = EntityPaddle.extend({
	animSheet: new ig.AnimationSheet( 'media/paddle-red.png', 64, 128 ),
});

});
