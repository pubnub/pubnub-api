var pubnub = require('./pubnub.js');
var network;

exports.setupNetwork = function(publish_key, subscribe_key, secret_key, ssl, origin) {
  network = pubnub.init({
    publish_key   : publish_key,
    subscribe_key : subscribe_key,
    secret_key    : secret_key,
    ssl           : ssl,
    origin        : origin 
  });
  return network; 
}


exports.listenToGame = function(players, games, entity_ownership, player_id) {
  network.subscribe({
    channel  : player_id + "_from_client",
    callback : function(message) {
      switch (message.type) {
        case "ent_update":
          console.log('received ' + message.type + ' on ' + message.id + ' from ' + player_id.substr(0,5)); 
          var player = players[player_id];
          var game = games[player.game];
          var entity = game.entities[message.id];

          if ((player === undefined) || (game === undefined) || (entity === undefined))
            break;
           
          entity.pos = message.pos;  // update position
          exports.sendToUser(player.opponent, message);  //forward on the message
          
          if (game.status !== 'started') {
            exports.sendToUser(player_id, {type: 'game_not_active'});
            break;
          }
          
          if (checkForWin(message.pos, player.which) == true) {
            exports.sendToUser(player_id, {type: 'you_win'});
            exports.sendToUser(player.opponent, {type: 'you_lose'});
            game.status = "won_by_" + player.which;
            break;
          }
    
          if (entity_ownership[message.id] !== "closest") //if it's not a static entity, we're done
            break;

          // find closest staticly-owned entity
          // set ownership to that entity's owner

          var closest = { 'distance': 100000, 'ent': undefined } ;
          for (var static_ent in game.entities) {
            if (game.entities[static_ent] === entity) {
              //console.log('compairing to the same ent, continue');
              continue;
            }
            if (entity_ownership[static_ent] === 'closest') {
              //console.log('entity we are compairing to is dynamic also, continue');
              continue;
            }
            if (game.entities[static_ent].pos === undefined) // fixing an unexplainable bug
              break;
            var dis = computeDistance(game.entities[static_ent].pos, entity.pos);
            if (dis < closest.distance) {
              closest =  {'distance': dis, 'ent': game.entities[static_ent]};
            }
          }

          if (entity.owned_by !== closest.ent.owned_by) {
            exports.sendToUser(game[closest.ent.owned_by], 
              {"id":   message.id,
               "type": "ent_now_yours",
               "pos":  entity.pos });
            exports.sendToUser(game[entity.owned_by], 
              {"id":   message.id, 
               "type": "ent_not_yours",
               "pos":  entity.pos });
            entity.owned_by = closest.ent.owned_by;
          }
          break;

        case "still_here":
          console.log('received ' + message.type + ' from ' + player_id.substr(0,5)); 
          clearTimeout(players[player_id].timeout);
          players[player_id].countdown = 3;
          break;

        default:
          console.log('received ' + message.type + ' from ' + player_id.substr(0,5)); 
          break;
          
      }      
    }
  });


};

var computeDistance = function(pos1, pos2) {
  return Math.sqrt( Math.pow((pos2.x - pos1.x), 2) + Math.pow((pos2.y - pos1.y), 2));
};


exports.verifyStillConnected = function(players, player_id) {
  var player = players[player_id];
  player.interval = setInterval( function() {

    exports.sendToUser(player_id, {'type': 'still_there'}, function(info) { 
      if (!info[0]) return;

      player.timeout = setTimeout( function() {
        console.log("player " + player_id.substr(0,5) + " countdown = " + player.countdown);

        if (--player.countdown > 0) 
          return;

        console.log("player " + player_id.substr(0,5) + " timeout" );
        clearInterval(player.interval);

        //todo: fix this 
        //if (queue === player_id)
        //  queue = undefined;  // if they were the queue, they're not anymore

        if (player.opponent !== undefined) 
          exports.sendToUser(player.opponent, {'type': 'opponent_left'});

      }, 2500 );

    });
  }, 3000 );

};


var checkForWin = function(puck_pos, player) {
  if ((puck_pos.x < 0) || (puck_pos.x > 700)) {
    return true;
  }
  return false;
};

exports.sendToUser = function(player_id, message, callback) { 
  if (!callback) {
    callback = function(info) {
      if (!info[0]) {
        console.log("Failed Message Delivery");
      }
    };
  }
  network.publish({
    channel  : player_id + "_from_server",
    message  : message,
    callback : callback 
  });

  switch (message.type) {
    case "ent_update": 
      console.log('sent ' + message.type + ' on ent ' + message.id+ ' to ' + player_id.substr(0,5)); 
      break; 

    case "still_there": 
      console.log('sent ' + message.type + ' to ' + player_id.substr(0,5)); 
      break; 

    default:
      console.log('sent ' + message.type + ' to ' + player_id.substr(0,5)); 
      break; 
  }
};

