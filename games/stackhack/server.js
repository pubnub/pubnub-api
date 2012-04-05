var app = require('express').createServer(),
    mime = require('mime'),
    fs = require('fs'),
    url = require("url"),
    pubnub = require('pubnub'),
    events  = new (require('events').EventEmitter)(),
    uuid = require('node-uuid'),
    mongoose = require('mongoose')
    settings = require('./settings.js');


var ClientInfoSchema = new mongoose.Schema({
  uuid :                  { type: String, default: '' },
  connected_timestamp  :  { type: Number, default: +new Date() },
  last_action_timestamp : { type: Number, default: +new Date() },
  blocks_created  :       { type: Number, default: 0 },
  blocks_removed  :       { type: Number, default: 0 },
  muted  :                { type: Boolean, default: false }
});

var BlockSchema = new mongoose.Schema({
  x :          { type: Number, default: 0 },
  y :          { type: Number, default: 0 },
  z :          { type: Number, default: 0 },
  color :      { type: Number, default: 0 },
  created_by : { type: String, default: '' },
  hash :       { type: String, default: '' }
});

var ServerInfoSchema = new mongoose.Schema({
  wipe :       { type: Number, default: +new Date() }
});

var ClientInfo = mongoose.model('ClientInfo', ClientInfoSchema),
    Block =      mongoose.model('Block', BlockSchema),
    ServerInfo = mongoose.model('ServerInfo', ServerInfoSchema);

var block_index = {}, 
    clients = {}, 
    updated = {},
    muted = {},
    wipe, 
    debug,
    channel;

if (debug == true) {
}
else {
}


var server_info;
setTimeout( function() {
  ServerInfo.findOne({}, function (err, the_server_info) {
    if (err) { console.log('err finding server_info: ' + err); }
    server_info = the_server_info;
    if (server_info != undefined) {
      if (server_info.wipe != undefined) {
        wipe = server_info.wipe; 
        if (getTimeTilWipe() <= 0) {
          wipeIt();
        }
        else {
          setTimeout(wipeIt, getTimeTilWipe());
        }
      }
      else {
        makeNewWipe();
      }
    }
    else {
      server_info = new ServerInfo();
      makeNewWipe();
    }
  });
}, 2000);

app.configure(function() {
  app.use(app.router);
  app.set("view engine", "html");
  app.set('view cache', false);
  app.register(".html", require("jqtpl").express);
});

app.configure("development", function() {
  global.ENV = "development";
  global.PORT = 7777;
  console.log("Starting under development settings...");
  mongoose.connect(settings.DEBUG_MONGODB_URL);
  channel = "stackhack_debug";
  debug = true;
});

app.configure("production", function() {
  global.ENV = "production";
  global.PORT = 80;
  console.log("Starting under production settings...");
  mongoose.connect(settings.PROD_MONGODB_URL);
  channel = "stackhack_public";
  debug = false;
});

app.get('/favicon.ico', function(req, res) {
  load_page("/media/img/favicon.ico", res);
});

app.get('/', function(req, res) {

  console.log('/');
  var new_client = addClient(uuid.v4()),
      block_array = objectToArray(block_index);

  console.log(block_array);
  res.render('main', {'debug': debug,
                      'layout': true, 
                      'uuid':   new_client.info.uuid,
                      'time_til_wipe':   getTimeTilWipe(),
                      'block_array': block_array });
});

function addClient(uuid, client_info) {
  if (client_info == undefined) {
    client_info = new ClientInfo();
    client_info.uuid = uuid;
    client_info.save(function (err) {
      if (err) { console.log("err: " + err); }
    });
  }


  var new_client = { 'info': client_info,
                     'sync': {
                       'countdown': 2,
                       'status': 'new',
                       'interval': undefined }
                   };

  console.log("adding client " + new_client.info.uuid);

  clients[client_info.uuid] = new_client;
  if (client_info.muted == true) {
    muted[client_info.uuid] = client_info.uuid;
    console.log("but they're muted.");
  }

  return new_client;
}

app.get('/*', function(req, res) {
  var path = escape(url.parse(req.url).pathname);
  console.log(path);
  if (path.split("/")[1] == "media") {
    load_page(path, res);
  }
  else {
    send_404(res);
  }
});

var send_404 = function(res){
  console.log("--> 404");
  load_page('/404.html', res);
};

var load_page = function(path, res){
  fs.readFile(__dirname + path, function(err, data){
    if (err) {
      console.log(err);
      return send_404(res);
    }
    res.writeHead(200,{ 'Content-Type': mime.lookup(path) });
    res.write(data, 'utf8');
    res.end();
  });
};

ClientInfo.find({}, function (err, client_infos) {
  Object.keys(client_infos).forEach(function(c) {
    client_info = client_infos[c];
    console.log('client: starting with ' + client_info.uuid);
    addClient(undefined, client_info);   
    setTimeout( sendStatus, 3000, client_info.uuid, true); 
  });

});

Block.find({}, function (err, blocks) {
  Object.keys(blocks).forEach(function(b) {
    block = blocks[b];
    console.log('block: starting with ' + block.x + ', ' + block.y + ', ' + block.z);
    block_index[block.hash] = block;
  });
});


app.listen(global.PORT);
console.log('Port ' + global.PORT);

var network = pubnub.init({
  publish_key   : settings.PUBNUB_PUBLISH_KEY,
  subscribe_key : settings.PUBNUB_SUBSCRIBE_KEY,
  secret_key    : settings.PUBNUB_SECRET_KEY,
  ssl           : false,
  origin        : "pubsub.pubnub.com" 
});

function messageClients(name, data) {
  var message = { "name": name,
                  "data": data,
                  "client": "server" };
  network.publish({
    channel  : channel,
    message  : message,
    callback : function(info) {
      if (!info[0]) { console.log(info[1]); }
      if (debug) { console.log("sent message: " + JSON.stringify(message)); }
    }
  });
}

function privateMessageClient(uuid, name, data) {
  if (uuid == "server") { return; }

  var message = { "name": name,
                  "data": data,
                  "client": "server"};
  network.publish({
    channel  : "stackhack_"  + uuid,
    message  : message,
    callback : function(info) {
      if (!info[0]) { console.log(info[1]); }
      if (debug) { console.log("sent private message to " + uuid +  ": " + JSON.stringify(message)); }
    }
  });
}

function privateMessageAllClients(name, data) {
  var client;
  Object.keys(clients).forEach(function(c) {
    client = clients[c];
    privateMessageClient(client.info.uuid, name, data);
  });
}

function hashBlock(x, y, z) {
  return x + "_" + y + "_" + z;
}

network.subscribe({
  channel  : channel,
  callback : function(message) {
    if (debug) { console.log("got message: " + JSON.stringify(message)); }
    if ((muted[message.client] != undefined) && ((message.name =="create") || (message.name == "remove"))) {
      if (debug) { console.log("Muted: Ignoring."); } 
      return;
    }
    events.emit("action", message); // generic action emiter, which will emit the appropriate action message
  },
  error : function(e) {
    console.log(e);
  }
});

setInterval( function() {
  Object.keys(clients).forEach(function(c) {
    client = clients[c];
    privateMessageClient(client.info.uuid, "still_there", {});
    client.sync.status = 'sent_check';  
    client.sync.timeout = setTimeout( clientDidntRespond, 2000, c);
  });
}, 30 * 1000);

function clientDidntRespond(c) {
  client = clients[c];
  if (client.sync.status == 'sent_check') {
    client.sync.countdown -= 1;
  }
  if (client.sync.countdown <= 0) {
    console.log(client.info.uuid + ' disc');
    client.info.remove();
    delete clients[c];
    if (muted[client.info.uuid] != undefined) {
      delete muted[client.info.uuid];
    }
  }
}

events.on("action", function(message) {
  client = clients[message.client];
  if (client == undefined) {
    client = addClient(message.client);
  }
  client.sync.status = "there";
  client.sync.countdown = 2;
  if (client.sync.timeout != undefined) {
    clearTimeout(client.sync.timeout);
  }
  events.emit(message.name, message, client);
});

events.on("create", function(message, client) {
  if (isBlockValid(message.data.x, message.data.y, message.data.z)) {
    var block = new Block();

    block.x = message.data.x;
    block.y = message.data.y;
    block.z = message.data.z;
    block.color = message.data.color;
    block.created_by = client.info.uuid;
    block.hash = hashBlock(message.data.x, message.data.y, message.data.z),
    
    block_index[block.hash] = block;

    block.save( function(err) {
      if (err) { console.log('err saving block: ' + err); }
    });
    client.info.blocks_created += 1;
    client.info.last_action_timestamp = +new Date();
    client.info.save();

  }
});


//IF YOU WANNA MUTE SOMEONE HERE'S HOW
/*
if (block.x == -475) {
  muteClient(client);
}
*/

function muteClient(client) {
  privateMessageAllClients("mute_client", {"muted_player": client.info.uuid });
  muted[client.info.uuid] = client.info.uuid;
  client.info.muted = true;
  client.info.save();
}

events.on("remove", function(message, client) {
  var place = hashBlock(message.data.x, message.data.y, message.data.z),
      block_to_remove;   
  if (block_index[place] != undefined) {
    block_index[place].remove(function(err) {
      if (err) { console.log('err remove block: ' + err); }
      delete block_index[place];
    });

    client.info.blocks_removed += 1;
    client.info.last_action_timestamp = +new Date();
    client.info.save();
  }
});

events.on("status", function(message, client) {
  sendStatus(client.info.uuid);
});



function objectToArray(obj) {
  var array = [];
  Object.keys(obj).forEach(function(b) {
    array.push(obj[b]);
  });
  return array;
}


function sendStatus(uuid, mini) {
  console.log('send status');

  var block_array = objectToArray(block_index),
      muted_array = objectToArray(muted),
      i, j, k, temp_array, chunk = 20, timestamp = +new Date(), 
      time_til_wipe = getTimeTilWipe(),
      num_clients = Object.keys(clients).length;

  console.log("time_til_wipe:");
  console.log(time_til_wipe);

  // if there's nothing
  if (block_array.length == 0) {
    privateMessageClient(uuid, "status", {
    "blocks": [],
    "time_til_wipe": time_til_wipe,
    "timestamp": timestamp, 
    "muted": muted_array,
    "num_clients": num_clients }); 
    return;
  }

  if (mini == true) {
    privateMessageClient(uuid, "mini_status", {
    "time_til_wipe": time_til_wipe }); 
    return;
  }

  for (i=0, j=block_array.length; i < j; i += chunk ) {
    temp_array = block_array.slice(i, i + chunk);

    // gotta get rid of the properties we don't want
    for (k=0; k < temp_array.length; k += 1) {
      temp_array[k] = {"x": temp_array[k].x,
                       "y": temp_array[k].y,
                       "z": temp_array[k].z,
                       "color": temp_array[k].color};
    }

    privateMessageClient(uuid, "status", {
      "blocks": temp_array,
      "time_til_wipe": time_til_wipe,
      "timestamp": timestamp,
      "muted": muted_array,
      "num_clients": num_clients }); 
  }
}

function isBlockValid(x, y, z) {
  var hash = hashBlock(x, y, z); 
  if (block_index[hash] != undefined) {
    return false;
  }
  if ((z > 475)  || (z < -475) || 
      (x > 475)  || (x < -475) ||
      (y > 875)  || (y < 0)) {
    return false;  
  }
  if ((((x - 25) % 50) != 0 ) ||
      (((y - 25) % 50) != 0 ) ||
      (((z - 25) % 50) != 0 )) {
    return false;  
  }
  return true;
}


setInterval( function() {
  if (Object.keys(clients).length < 3) {
    fakeOps();
  }
}, 1000 * 60 );

function fakeOps() {
  console.log('fake ops!!!!');
  var x, y, z, c, hash, color,
      num_actions = Math.floor(Math.random()*60) + 5,
      time_increment = ((1000 * 30) / num_actions),
      which_direction, i, rgorb, attempts_to_move = 0, coords;

  console.log('num_actions: ' + num_actions);
  console.log('time_increment (in ms): ' + time_increment);

  do {
    x = (Math.floor(Math.random()*20) - 10) * 50 + 25;
    y = 25;
    z = (Math.floor(Math.random()*20) - 10) * 50 + 25;
    c = Math.floor(Math.random()*16777215);
  }
  while (isBlockValid(x,y,z) == false);
  color = parseInt('0x' + c.toString(16));
  messageClients("create", {"x": x, "y": y, "z": z, "color": color, "client": "server"} );

  for (i=0; i < num_actions; i+=1) {
    which_direction = Math.floor(Math.random()*5);
    console.log('which_direction: ' + which_direction);
    coords = moveADirection(x, y, z, which_direction, false);
    x= coords[0]; y= coords[1]; z= coords[2];

    if (isBlockValid(x, y, z) == false) {
      attempts_to_move += 1;
      if (attempts_to_move > 4) {
        break;
      }
      i -= 1;
      coords = moveADirection(x, y, z, which_direction, true); //reverse previous action
      x= coords[0]; y= coords[1]; z= coords[2];
      continue;
    }
    attempts_to_move = 0;
    rgorb = Math.floor(Math.random()*3);
    switch (rgorb) {
      case 0: 
        c += Math.floor(Math.random()*10);
        break;
      case 1: 
      c += (256 + Math.floor(Math.random()*10));
        break;
      case 2: 
      c += ((256 * 256) + Math.floor(Math.random()*10));
        break;
    }
    color = parseInt('0x' + c.toString(16));
    console.log('going to send out create for ' + x + ', ' + y + ', '+ z + ' in ' + ((time_increment * i) / 1000) + ' seconds');
    setTimeout( messageClients, (time_increment * i), "create", {"x": x, "y": y, "z": z, "color": c, "client": "server"});
  }
}

function moveADirection(x, y, z, direction, reverse) {
  var distance;
  if (reverse == true) {
    distance = -50;
  }
  else {
    distance = 50;
  }

  switch(direction) {
    case 0:
      x += distance;
      break;
    case 1:
      x -= distance;
      break;
    case 2:
      y += distance;
      break;
    case 3:
      z -= distance;
      break;
    case 4:
      z += distance;
      break;
  }
  return [x, y, z]; 
}


/****** WIPE STUFF ******/

setTimeout( function() {
  // if we didn't load a wipe from the db, set it
  if (wipe == undefined) { 
    console.log('wipe didnt load from the db');
    wipe = +new Date() + (calculateNextWipe());
  }
}, 2000);

function getTimeTilWipe() {
  var now = +new Date();
  time_til_wipe = (wipe - now);   
  return time_til_wipe;
}

function wipeIt() {
  console.log("wipe!");

  Object.keys(block_index).forEach(function(b) {
    block_index[b].remove(function(err) {
      if (err) { console.log('err removing block: ' + err); }
      delete block_index[b];
    });
  });

  makeNewWipe();
  privateMessageAllClients("wipe", {"next": getTimeTilWipe()});

}


function makeNewWipe() {
  wipe = +new Date() + (calculateNextWipe());
  setTimeout(wipeIt, getTimeTilWipe());
  server_info.wipe = wipe;
  server_info.save(function (err) {
    if (err) { console.log("err saving server_info: " + err); }
  });
}

function calculateNextWipe() {
  var num_clients = Object.keys(clients).length,
      wipe_data = {
        0: 10, 
        1: 10,
        2: 8,
        3: 6,
        4: 5,
        5: 4,
        6: 4,
        7: 3,
        8: 2
      },
      min = wipe_data[num_clients]; 

  if (min == undefined) { min = 2; }
  return min * 60 * 1000; 


}


/****** END WIPE STUFF *****/


