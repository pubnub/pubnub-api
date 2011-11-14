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
    var p = PUBNUB;

		ig.input.bind( ig.KEY.UP_ARROW, 'up' );
		ig.input.bind( ig.KEY.DOWN_ARROW, 'down' );
		
		this.loadLevel( LevelMain );

    // when a message comes in, it's type maps to one of the following event
    // note there also events at the plugin level
    p.events.bind("in_queue", function(message) {
      console.log("in_queue");  
    });

    p.events.bind("game_found", function(message) {
      console.log("game_found");  
      game_obj.which_player = message.which_player;
      game_obj.getPuck().startMoving();
      game_obj.game_status = "in_game";
      if (game_obj.which_player == "player_1") {
        game_obj.getPaddle2().keepUpdated();
        game_obj.getPaddle1().belongs_to_me = true;
      }
      else {
        game_obj.getPaddle1().keepUpdated();
        game_obj.getPaddle2().belongs_to_me = true;
        game_obj.getPuck().belongs_to_me = true;
      }
      game_obj.getPuck().keepUpdated(message.which_player);
    });

    p.events.bind("opponent_left", function(message) {
      console.log('opponent left');
    });

    p.events.bind("you_win", function(message) {
      game_obj.player_notification = 'You win!';
      game_obj.getPuck().stopMoving(); 
      //game_obj.getPuck().stopUpdating();
      //game_obj.getPaddle1().stopUpdating();
      //game_obj.getPaddle2().stopUpdating();
    });

    p.events.bind("you_lose", function(message) {
      game_obj.player_notification = 'You lose!';
      game_obj.getPuck().stopMoving(); 
      //game_obj.getPuck().stopUpdating();
      //game_obj.getPaddle1().stopUpdating();
      //game_obj.getPaddle2().stopUpdating();
    });

    p.events.bind("game_not_active", function(message) {
      console.log("game not active");
    });


    //start the game
    setTimeout( function() {
      p.events.fire("send_to_lobby", {'type':'looking_for_game'}); 
    }, 2000);

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
    if (puck.belongs_to_me === true) {
      this.font.draw("belongs_to_me", puck.pos.x, puck.pos.y );
    }
    if (paddle1.belongs_to_me === true) {
      this.font.draw("belongs_to_me", paddle1.pos.x + 15, paddle1.pos.y + 5 );
    }
    if (paddle2.belongs_to_me === true) {
      this.font.draw("belongs_to_me", paddle2.pos.x + 15, paddle2.pos.y + 5 );
    }
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


