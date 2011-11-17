var pubnub = require('./pubnub.js');
var network;
var clients = {};


// node.js events are not working,
// let's define a simple event system
function each( o, f ) {
    if ( !o || !f ) return;

    if ( typeof o[0] != 'undefined' )
        for ( var i = 0, l = o.length; i < l; )
            f.call( o[i], o[i], i++ );
    else
        for ( var i in o )
            o.hasOwnProperty    &&
            o.hasOwnProperty(i) &&
            f.call( o[i], i, o[i] );
}

var event = exports.events  = {
  list : {},
  bind : function( name, fun ) {
    (event.list[name] = event.list[name] || []).push(fun);
  },
  fire : function( name, data ) {
    each(
      event.list[name] || [],
      function(fun) { fun(data) }
    );
  },
}


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

  // bind events
  exports.events.bind('ent_update_' + player_id, function(message) {
    console.log('received ' + message.type + ' on ' + message.id + ' from ' + player_id.substr(0,5)); 
    var player = players[player_id];
    var game = games[player.game];
    var entity = game.entities[message.id];

    if ((player === undefined) || (game === undefined) || (entity === undefined))
      return;
     
    entity.pos = message.pos;  // update position
    exports.sendToUser(player.opponent, message);  //forward on the message
    
    if (game.status !== 'started') {
      exports.sendToUser(player_id, {type: 'game_not_active'});
      return;
    }
    
    if (checkForWin(message.pos, player.which) == true) {
      exports.sendToUser(player_id, {type: 'you_win'});
      exports.sendToUser(player.opponent, {type: 'you_lose'});
      game.status = "won_by_" + player.which;
      return;
    }

    if (entity_ownership[message.id] !== "closest") //if it's not a static entity, we're done
      return;

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
        return;
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

  });

  exports.events.bind('still_here_' + player_id, function(message) {
    console.log('received ' + message.type + ' from ' + player_id.substr(0,5)); 
    clearTimeout(players[player_id].timeout);
    clients[player_id].countdown = 3;
  });
  
  exports.events.bind('ent_update_' + player_id, function(message) {
  });

  network.subscribe({
    channel  : player_id + "_from_client",
    callback : function(message) {
      exports.events.fire(message.type + '_' + player_id, message);
    }
  });
};

var computeDistance = function(pos1, pos2) {
  return Math.sqrt( Math.pow((pos2.x - pos1.x), 2) + Math.pow((pos2.y - pos1.y), 2));
};


exports.verifyStillConnected = function(player_id) {
  var client = clients[player_id] = { 
    'interval': undefined,
    'timeout': undefined,
    'countdown': undefined };

  client.interval = setInterval( function() {
    exports.sendToUser(player_id, {'type': 'still_there'}, function(info) { 
      if (!info[0]) return;

      client.timeout = setTimeout( function() {
        if (--client.countdown > 0) 
          return;

        exports.events.fire("client_disconnected", player_id );
        clearInterval(client.interval);

      }, 1250 );

    });
  }, 1500 );

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

