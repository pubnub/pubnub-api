ig.module( 
	'plugins.pubnub.game'
)
.requires(
	'plugins.pubnub.lib',
	'impact.game'
)
.defines(function(){


  ig.PubNubGame = ig.Game.extend({

    loadLevel: function( data ) {
      console.log(data); 
      console.log('pubnub!'); 
      this.parent(data);
    },
	

  });

});
