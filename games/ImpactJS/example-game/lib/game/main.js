ig.module( 
	'game.main' 
)
.requires(
	'impact.game',
	'impact.font',
	
	'game.entities.puck',
	'game.entities.paddle-p1',
	'game.entities.paddle-p2',
	
	'game.levels.main',
  'plugins.pubnub.game'
)
.defines(function(){

MyGame = ig.PubNubGame.extend({

  game_status: "not_in_game",
	// Load a font
	font: new ig.Font( 'media/04b03.font.png' ),
	
	init: function() {
    this.parent();
    var game_obj = this;

		ig.input.bind( ig.KEY.UP_ARROW, 'up' );
		ig.input.bind( ig.KEY.DOWN_ARROW, 'down' );
		
		this.loadLevel( LevelMain );

	},

	
	update: function() {
		// Update all entities and backgroundMaps
		this.parent();
    var game_obj = this;
	},
	
	draw: function() {
		// Draw all entities and backgroundMaps
		this.parent();
    puck = this.getPuck();
    paddle1 = this.getPaddle1();
    paddle2 = this.getPaddle2();
    this.font.draw(puck.belongs_to, puck.pos.x, puck.pos.y );
    this.font.draw(paddle1.belongs_to, paddle1.pos.x + 15, paddle1.pos.y + 5 );
    this.font.draw(paddle2.belongs_to, paddle2.pos.x + 15, paddle2.pos.y + 5 );
    this.font.draw("you are " + this.which_player, 370, 100 );
    this.font.draw(this.player_notification, 370, 80 );
	},

  loadLevel: function(data) {
    this.parent(data);
  },

  getPuck: function() {
    return this.getEntitiesByType('EntityPuck')[0];
  },

  getPaddle1: function() {
    return this.getEntitiesByType('EntityPaddlePlayer1')[0];
  },

  getPaddle2: function() {
    return this.getEntitiesByType('EntityPaddlePlayer2')[0];
  },

});


ig.main( '#canvas', MyGame, 60, 768, 480, 1 );

});


