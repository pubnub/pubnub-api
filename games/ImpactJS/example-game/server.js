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

var queue = undefined;


ip.events.bind('looking_for_game', function(message) {

  ip.initPlayer(message.player_id);

  // if player that's in queue disconnects, remove him from the queue 
  ip.events.bind('disconnected_' + message.player_id, function(message) {
    if (queue !== undefined) queue = undefined;
  });

  if (queue === undefined) { 
    queue = message.player_id;
    ip.sendToUser(message.player_id, {'type': 'in_queue'});
  } 
  else {

    var initial_positions = {'1': {'pos': {'x':380, 'y':212 }, 
                             'owned_by': message.player_id, 
                             'dynamic': true },

                             '2': {'pos': {'x':8,   'y':168 }, 
                             'owned_by': queue, 
                             'dynamic': false },

                             '3': {'pos': {'x':696, 'y':164 }, 
                             'owned_by': message.player_id, 
                             'dynamic': false}};


    ip.startGame([queue, message.player_id], initial_positions);

    var x = 1;
    [queue, message.player_id].forEach( function(player) {
      // every ent update, we need to be checking for a win
      ip.events.bind('ent_update_' + player, function(message) {
        if (checkForWin(message.pos) == true) {
          //exports.sendToUser(player_id, {type: 'you_win'});
          console.log('someone won');
          return;
        }
      });

      ip.sendToUser(player, {'type': 'game_found', 'which_player': "player_" + x });

      setTimeout( function() {
        ip.sendToUser(player, {'type': 'game_start' });
      }, 3000);
      x++;
    });
    queue = undefined;
  }
});

ip.events.bind('client_disconnected', function(player_id) {
  if (queue === player_id)
    queue = undefined;  // if they were the queue, they're not anymore
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

var checkForWin = function(puck_pos) {
  if ((puck_pos.x < 0) || (puck_pos.x > 700)) {
    return true;
  }
  return false;
};

console.log('Port ' + global.PORT);



