"use strict";

var http = require('http');
var fs = require("fs");
var url = require("url");
var express = require("express");
var mime = require("mime");
var impact = require('impact');
var pubnub = require('./pubnub.js');

var app = express.createServer();

app.configure(function() {
    app.use(express.methodOverride());
    app.use(express.bodyParser());
    app.use(app.router);
    });

app.configure("development", function() {
    global.ENV = "development";
    global.PORT = 7777;
    console.log("Starting under development settings...");
    });

app.configure("production", function() {
    global.ENV = "production";
    global.PORT = 80;
    console.log("Starting under production settings...");
    });

app.listen(global.PORT);

app.get('/', function(req, res) {
    console.log('/');
    load_page('/index.html', res);
    });

app.get('/editor', function(req, res) {
    console.log('/editor');
    load_page('/weltmeister.html', res);
    });


var im = impact.listen(app, { root: __dirname  });
app.use(express.static(im.root));

var render_page = function(template_name, res, context) {
  var template_path = './templates/' + template_name + '.jade';
  options = { locals: context };
  if (global.ENV === "development") {
    options.compileDebug = true;     
    options.inline = false;     
  }
  jade.renderFile(template_path, options, function(err, html) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end(html);
  });
};

var send_404 = function(res){
  console.log("  (404)");
  //render_page('404', res, {});
};

var load_page = function(path, res ){
  fs.readFile(__dirname + path, function(err, data){
    if (err) {
      return send_404(res);
    }
    var content_type = mime.lookup(path);

    res.writeHead(200,{ 'Content-Type': content_type });
    res.write(data, 'utf8');
    res.end();
  });
};

var network = pubnub.init({
  publish_key   : "demo",
  subscribe_key : "demo",
  secret_key    : "",
  ssl           : false,
  origin        : "pubsub.pubnub.com"
});

var players = {};
var queue = undefined;
var games = {};
var opponents = {};
var entity_ownership =  {'1': 'closest',
                         '2': 'player_1',
                         '3': 'player_2' };
var initial_positions = {'1': {'pos': {'x':380, 'y':212 }, 'owned_by': 'player_2'},
                         '2': {'pos': {'x':8,   'y':168 }, 'owned_by': 'player_1'},
                         '3': {'pos': {'x':696, 'y':164 }, 'owned_by': 'player_2'}};

// will need this later
Object.prototype.clone = function() {
  var newObj = (this instanceof Array) ? [] : {};
  for (var i in this) {
    if (i == 'clone') continue;
    if (this[i] && typeof this[i] === "object") {
      newObj[i] = this[i].clone();
    } else newObj[i] = this[i];
  } return newObj;
};

var sendToUser = function(player_id, message, callback) { 
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

var listenToGame = function(player_id) {
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
          sendToUser(player.opponent, message);  //forward on the message
          
          if (game.status !== 'started') {
            sendToUser(player_id, {type: 'game_not_active'});
            break;
          }
          
          if (checkForWin(message.pos, player.which) == true) {
            sendToUser(player_id, {type: 'you_win'});
            sendToUser(player.opponent, {type: 'you_lose'});
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
            sendToUser(game[closest.ent.owned_by], 
              {"id":   message.id,
               "type": "ent_now_yours",
               "pos":  entity.pos });
            sendToUser(game[entity.owned_by], 
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


var verifyStillConnected = function(player_id) {
  var player = players[player_id];
  player.interval = setInterval( function() {

    sendToUser(player_id, {'type': 'still_there'}, function(info) { 
      if (!info[0]) return;

      player.timeout = setTimeout( function() {
        console.log("player " + player_id.substr(0,5) + " countdown = " + player.countdown);

        if (--player.countdown > 0) 
          return;

        console.log("player " + player_id.substr(0,5) + " timeout" );
        clearInterval(player.interval);

        if (queue === player_id)
          queue = undefined;  // if they were the queue, they're not anymore

        if (player.opponent !== undefined) 
          sendToUser(player.opponent, {'type': 'opponent_left'});

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

network.subscribe({
  channel  : "pong_lobby",
  callback : function(message) {
    switch (message.type) {
      case "looking_for_game":
        players[message.player_id] = { 
         'opponent': undefined,
         'game': undefined,
         'which': undefined,
         'interval': undefined,
         'timeout': undefined,
         'countdown': undefined };

        verifyStillConnected(message.player_id);
        listenToGame(message.player_id);                    

        if (queue === undefined) { 
          queue = message.player_id;
          sendToUser(message.player_id, {'type': 'in_queue'});
        } 
        else {
          var game_id = queue.substr(0,4) + message.player_id.substr(0,4);
          games[game_id] = { 'player_1': queue, 
                             'player_2': message.player_id,
                             'entities': initial_positions.clone(),
                             'status':   'not_started'}; 

          players[message.player_id].opponent = queue;
          players[message.player_id].which = 'player_2';
          players[message.player_id].game = game_id;

          players[queue].opponent = message.player_id;
          players[queue].which = 'player_1';
          players[queue].game = game_id;

          sendToUser(message.player_id, {'type': 'game_found',
                                        'game': game_id,
                                        'which_player': "player_2" });
          sendToUser(queue, {'type': 'game_found',
                             'game': game_id,
                             'which_player': "player_1" });
          games[game_id].status = 'started';
        
          queue = undefined;
        }
        break;

      default:
        console.log("bad message type");
        break;
    }
      



  },
  error : function() {
    console.log("Network Connection Dropped");
  }
});

console.log('Port ' + global.PORT);



