var pubnub = require('./pubnub.js');
var network;
exports.clients = {};


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

// args:
// 0: an array of players
// 1: object of initial positons (of entities) and their ownership
exports.startGame = function(players, entities) {
  //for (var i; i < players.length; i++ ) {
  players.forEach( function(player_id) {
    //var player_id = players[i];

    // bind events
    exports.events.bind('ent_update_' + player_id, function(message) {
      console.log('received ' + message.type + ' on ' + message.id + ' from ' + player_id.substr(0,5)); 
       
      var entity = entities[message.id];
      entity.pos = message.pos;  // update position

      // send msg to all other players in room
      players.forEach( function(other_player) {
        if (other_player !== player_id) { 
          exports.sendToUser(other_player, message);
        }
      });

     
      if (entity.dynamic == false) // if it's a static entity, we're done
        return;

      // find closest staticly-owned entity
      // set ownership to that entity's owner

      var closest = { 'distance': 100000, 'ent': undefined } ;
      for (var ent_id in entities) {
        var static_ent = entities[ent_id];

        if (static_ent === entity) {
          continue; //if it's the same, don't care 
        }
        if (static_ent.dynamic) {
          continue;  // if it's also dynamic, don't care
        }


        var dis = computeDistance(static_ent.pos, entity.pos);
        if (dis < closest.distance) {
          closest =  {'distance': dis, 'ent': static_ent};
        }
      }

      if (entity.owned_by !== closest.ent.owned_by) {
        exports.sendToUser(closest.ent.owned_by, 
          {"id":   message.id,
           "type": "ent_now_yours",
           "pos":  entity.pos });
        exports.sendToUser(entity.owned_by, 
          {"id":   message.id, 
           "type": "ent_not_yours",
           "pos":  entity.pos });
        entity.owned_by = closest.ent.owned_by;
      }

    });

    exports.events.bind('disconnected_' + player_id, function(message) {
      console.log("player " + player_id.substr(0,5) + " left");
      for (var i; i < players.length; i++) {   
        if (players[i] == player_id) continue; 
        exports.sendToUser(player.opponent, {'type': 'player_disconnected', 
                                             'player_id': player_id});
      }
    });


  });
};

var computeDistance = function(pos1, pos2) {
  return Math.sqrt( Math.pow((pos2.x - pos1.x), 2) + Math.pow((pos2.y - pos1.y), 2));
};


exports.initPlayer = function(player_id) {
  network.subscribe({
    channel  : player_id + "_from_client",
    callback : function(message) {
      exports.events.fire(message.type + '_' + player_id, message);
    }
  });

  var client = exports.clients[player_id] = { 
    'interval': undefined,
    'timeout': undefined,
    'countdown': undefined };

  exports.events.bind('still_here_' + player_id, function(message) {
    //console.log('received ' + message.type + ' from ' + player_id.substr(0,5)); 
    clearTimeout(client.timeout);
    client.countdown = 3;
  });

  client.interval = setInterval( function() {
    exports.sendToUser(player_id, {'type': 'still_there'}, function(info) { 
      if (!info[0]) return;

      client.timeout = setTimeout( function() {
        if (--client.countdown > 0) 
          return;

        var interval_to_clear = client.interval;
        exports.events.fire("disconnected_" + player_id, {});
        delete client; 
        clearInterval(interval_to_clear);

      }, 1250 );

    });
  }, 1500 );

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
      //console.log('sent ' + message.type + ' to ' + player_id.substr(0,5)); 
      break; 

    default:
      console.log('sent ' + message.type + ' to ' + player_id.substr(0,5)); 
      break; 
  }
};

