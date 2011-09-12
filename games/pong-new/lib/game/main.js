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
	
	// Load a font
	font: new ig.Font( 'media/04b03.font.png' ),
	
	init: function() {
		ig.input.bind( ig.KEY.UP_ARROW, 'up' );
		ig.input.bind( ig.KEY.DOWN_ARROW, 'down' );
		
		this.loadLevel( LevelMain );

                
	},
	
	update: function() {
		// Update all entities and backgroundMaps
		this.parent();
		
		// Add your own, additional update code here
	},
	
	draw: function() {
		// Draw all entities and backgroundMaps
		this.parent();
    this.font.draw(this.game_status, 350, 30 );
	},

  getPaddle1: function() {
    return this.getEntitiesByType('EntityPaddlePlayer1')[0];
  },

  getPaddle2: function() {
    return this.getEntitiesByType('EntityPaddlePlayer2')[0];
  },

  getPuck: function() {
    return this.getEntitiesByType('EntityPuck')[0];
  },

  game_status: "connecting", // game state i.e. 'looking_for_game' etc
  player_uuid: "", // player identifier
  game_uuid: "", // game identifier
  player_paddle: undefined,
  opponent_paddle: undefined,
  latency: 0,
  opponent_latency: 0,
  latency_tests: [],
  is_host: false, // whether or not the player is the host


  startGame: function(extra_milliseconds) {
    console.log('starting game!');
    var game_obj = this;
    setTimeout( function() {
      game_obj.getPuck().startMoving();
    }, (3000 + extra_milliseconds));
  },

  loadLevel: function(data) {
    this.findMatch();
    this.parent(data);
  },

  findMatch: function() {
    var game_obj = this;
    PUBNUB.subscribe({
      channel  : "pong",    
      error    : function() {    
        console.log("Connection Lost. This game isn't going to work.")
        game_obj.game_status = "connection_lost_finding_game";
      },
      callback : function(message) { 
        // first let's make sure this isn't our own message
        if (message.player_uuid != game_obj.player_uuid) {
          switch (message.type) {
            case "looking_for_game":
              if (game_obj.game_status == "looking_for_game") {
                //potential match found!
                game_obj.game_status = 'found_potential_match';
                PUBNUB.publish({
                    channel : "pong",
                    message : { "player_uuid": game_obj.player_uuid,
                                "type": "lets_play_ill_host", }
                });
              }
              break;

            case "lets_play_ill_host":
              if (game_obj.game_status == "looking_for_game") {
                //confirmed match found!
                PUBNUB.uuid(function(uuid) { //generate a game_uuid
                  game_obj.game_uuid = uuid;
                  game_obj.game_status = 'found_match';
                  game_obj.player_paddle = game_obj.getPaddle2();
                  game_obj.opponent_paddle = game_obj.getPaddle1();
                  game_obj.getPaddle2().is_local_player = true;
                  game_obj.getPaddle2().game_uuid = game_obj.game_uuid;
                  game_obj.getPaddle2().player_uuid = game_obj.player_uuid;
                  console.log('match really found for offhost (p2)');
                  PUBNUB.publish({
                    channel : "pong",
                    message : { "player_uuid": game_obj.player_uuid,
                                "game_uuid": game_obj.game_uuid,
                                "type": "challenge_accepted" }
                  });
                  game_obj.setupMatch();
                });    
              }
              break;

            case "challenge_accepted":
              if (game_obj.game_status == "found_potential_match") {
                //confirmed match found!
                game_obj.game_status = 'found_match';
                game_obj.game_uuid = message.game_uuid;
                game_obj.player_paddle = game_obj.getPaddle1();
                game_obj.opponent_paddle = game_obj.getPaddle2();
                game_obj.getPaddle1().is_local_player = true;
                game_obj.getPaddle1().game_uuid = game_obj.game_uuid;
                game_obj.getPaddle1().player_uuid = game_obj.player_uuid;
                console.log('match really found for host (p1) ');
                game_obj.is_host = true;
                game_obj.setupMatch();
              }
              break;


          }
        }
      },
      connect  : function() { 
        PUBNUB.uuid(function(uuid) {
          game_obj.player_uuid = uuid; 
          PUBNUB.publish({
            channel : "pong",
            message : { "player_uuid": game_obj.player_uuid,
                        "type": "looking_for_game", }
          })
          game_obj.game_status = "looking_for_game";
        });
      }
    });
  },

  setupMatch: function() {
    console.log("setting up match");
    var game_obj = this;
    PUBNUB.subscribe({
      channel  : "pong_" + game_obj.game_uuid,    
      error    : function() {    
        console.log("Connection Lost. Game Over")
        game_obj.game_status = "game_over"
      },
      callback : function(message) { 
        // first let's make sure this isn't our own message
        if (message.player_uuid != game_obj.player_uuid) {
          switch (message.type) {
            case "moving_up":
              game_obj.opponent_paddle.last_broadcasted_state = 'moving_up';
              console.log('opponent moving up');
              break;

            case "moving_down":
              console.log('opponent moving down');
              game_obj.opponent_paddle.last_broadcasted_state = 'moving_down';
              break;

            case "not_moving":
              console.log('opponent not moving');
              game_obj.opponent_paddle.last_broadcasted_state = 'not_moving';
              game_obj.opponent_paddle.last_broadcasted_y = message.pos_y;
              break;

            case "lets_play":
              console.log('opponent wants to play!');
              game_obj.startGame(0);
              break;

            case "share_latency":
              console.log('sharing latency');
              game_obj.opponent_latency = message.latency;
              if ((game_obj.latency != 0) && (game_obj.opponent_latency != 0) && (game_obj.is_host == true)) {
                console.log('lets fucking play');
                PUBNUB.publish({
                    channel : "pong_" + game_obj.game_uuid,
                    message : { "type": "lets_play",
                                "player_uuid": game_obj.player_uuid }
                });
                console.log('lets fucking play');
                game_obj.startGame(game_obj.opponent_latency);
                console.log('lets fucking play');
              }
              break;
          }
        }
        else {
          switch (message.type) {
            case "latency_test":
              var current_date = new Date;
              var latency = ((current_date.getTime() - message.before_test) / 2);
              game_obj.latency_tests.push(latency);
              if (game_obj.latency_tests.length < 10) {
                game_obj.testLatency();
                break; 
              }
              console.log("latency_tests: " + game_obj.latency_tests);
              game_obj.computeAverageLatency(); 
              setTimeout( function() {
                game_obj.shareLatency(); 
              }, 1000);
              break; 

          }
        }
      },
      connect : function() { 
        console.log("connected to " + "pong_" + game_obj.game_uuid);    
        game_obj.testLatency();
      }
    });
  },

  testLatency: function() {
    var game_obj = this;
    var current_date = new Date;
    PUBNUB.publish({
        channel : "pong_" + game_obj.game_uuid,
        message : { "before_test": current_date.getTime(),
                    "type": "latency_test",
                    "player_uuid": game_obj.player_uuid }
    });
  },

  computeAverageLatency: function() {
    var game_obj = this;

    console.log("computing average latency");
    var total = 0;

    for (var i = 0; i < game_obj.latency_tests.length; i++) {
      total += game_obj.latency_tests[i];
    }

    console.log("total: " + total);
    var initial_average = (total / game_obj.latency_tests.length);
    console.log("initial_average: " + initial_average);

    for (var i = 0; i < game_obj.latency_tests.length; i++) {
      if ( game_obj.latency_tests[i] > (initial_average * 1.5)) {
        // throw out the outliers
        total -= game_obj.latency_tests[i];
        console.log("threw out " + game_obj.latency_tests[i]);
      }
    }

    game_obj.latency = (total / game_obj.latency_tests.length);
    console.log("game_obj.latency: " + game_obj.latency);
  },

  shareLatency: function() {
    var game_obj = this;
    PUBNUB.publish({
        channel : "pong_" + game_obj.game_uuid,
        message : { "type": "share_latency",
                    "latency": game_obj.latency,
                    "player_uuid": game_obj.player_uuid }
    });
  },
});


ig.main( '#canvas', MyGame, 60, 768, 480, 1 );

});


