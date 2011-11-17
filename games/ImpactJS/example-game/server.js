var http = require('http');
var fs = require("fs");
var url = require("url");
var express = require("express");
var mime = require("mime");
var impact = require('impact');
var ip = require('./impact-pubnub.js');
var events = require('events');
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

var network = ip.setupNetwork("demo", "demo", "", false, "pubsub.pubnub.com");

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




ip.events.bind('looking_for_game', function(message) {
  players[message.player_id] = { 
   'opponent': undefined,
   'game': undefined,
   'which': undefined,
   'interval': undefined,
   'timeout': undefined,
   'countdown': undefined };

  ip.verifyStillConnected(message.player_id);
  ip.listenToGame(players, games, entity_ownership, message.player_id);                    

  if (queue === undefined) { 
    queue = message.player_id;
    ip.sendToUser(message.player_id, {'type': 'in_queue'});
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

    ip.sendToUser(message.player_id, {'type': 'game_found',
                                  'game': game_id,
                                  'which_player': "player_2" });
    ip.sendToUser(queue, {'type': 'game_found',
                          'game': game_id,
                          'which_player': "player_1" });

    setTimeout( function() {
      ip.sendToUser(message.player_id, {'type': 'game_start' });
      ip.sendToUser(queue, {'type': 'game_start'} );
      games[game_id].status = 'started';
      queue = undefined;
    }, 3000);
  }
});

ip.events.bind('client_disconnected', function(player_id) {
  console.log("player " + player_id.substr(0,5) + " left");

  //TODO fix this 
  //if (queue === player_id)
  //  queue = undefined;  // if they were the queue, they're not anymore

  // TODO notify opponent of left
  //if (client.opponent !== undefined) 
  //  exports.sendToUser(client.opponent, {'type': 'opponent_left'});
});


network.subscribe({
  channel  : "pong_lobby",
  callback : function(message) {
    ip.events.fire(message.type, message);
  },
  error : function() {
    console.log("Network Connection Dropped");
  }
});

console.log('Port ' + global.PORT);



