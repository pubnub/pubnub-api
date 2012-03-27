var flatiron = require('flatiron'),
    path = require('path'),
    plates = require('plates'),
    fs = require('fs'),
    ecstatic = require('ecstatic'),
    pubnub = require('pubnub'),
    events  = new (require('events').EventEmitter)(),
    settings = require('./settings.js'),
    uuid = require('node-uuid'),
    https  = require('https'),
    http  = require('http');

var app = flatiron.app;
app.config.file({ file: path.join(__dirname, 'config', 'config.json') });
app.use(flatiron.plugins.http);

var debug = true;

app.router.get('/viewer', function () {
  console.log('/viewer');
  var flat = this;
  fs.readFile('viewer.html', function(err, buffer) {
    //console.log(file);
    var html = buffer.toString();
    var data = { "test": "New Value" };
    var output = plates.bind(html, data); 

    flat.res.writeHead(200, { 'Content-Type': 'text/html' });
    flat.res.end(output);
  });
});

app.router.get('/commander', function () {
  console.log('/commander');
  var flat = this;
  fs.readFile('m-commander.html', function(err, buffer) {
    //console.log(file);
    var html = buffer.toString();
    var data = { "uuid": uuid.v4() };
    var output = plates.bind(html, data); 

    flat.res.writeHead(200, { 'Content-Type': 'text/html' });
    flat.res.end(output);
  });
});


app.http.before = [
  ecstatic(__dirname + '/media', {autoIndex: false})
];

function fail() {
  console.log('fail');
}



var PORT = 3000;
app.start(PORT);
console.log('BOOM port ' + PORT);


/****** PUBNUB *******/

var network = pubnub.init({
  publish_key   : settings.PUBNUB_PUBLISH_KEY,
  subscribe_key : settings.PUBNUB_SUBSCRIBE_KEY,
  secret_key    : settings.PUBNUB_SECRET_KEY,
  ssl           : false,
  origin        : "pubsub.pubnub.com" 
});

network.subscribe({
  channel  : "content_commander",
  callback : function(message) {
    if (debug) { console.log("got message: " + JSON.stringify(message)); }
    events.emit(message.name, message);
  },
  error : function(e) {
    console.log(e);
  }
});

function sendPrivateMessage(uuid, name, data) {
  var message = { "name": name, "data": data },
      channel = "content_commander_" + uuid;
  console.log("channel:");
  console.log(channel);
  network.publish({
    channel  : "content_commander_" + uuid,
    message  : message, 
    callback : function(info) {
      if (!info[0]) { console.log(info[1]); }
      if (debug) { console.log("sent message: " + JSON.stringify(message)); }
    }
  });
}

events.on("youtube_search", function(message) {
  console.log("youtube_search:");
  console.log(message.data.query);
  search_youtube(message.data.query, message.uuid);
});

events.on("soundcloud_search", function(message) {
  console.log("soundcloud_search:");
  console.log(message.data.query);
  search_soundcloud(message.data.query, message.uuid);
});

function search_youtube(query, uuid) {
  var body = '';

  https.get( {
    host: 'gdata.youtube.com',
    path: '/feeds/api/videos?q=' + escape(query) + '&alt=json&orderby=relevance',
    method: 'GET'
  }, function(response) {
    response.setEncoding('utf8');
    response.on( 'error', fail );
    response.on( 'data', function (chunk) {
        if (chunk) body += chunk;
    });
    response.on( 'end', function () {

      var entries = JSON.parse(body).feed.entry, 
          video_ids = [];

      entries.forEach( function(entry) {
        video_ids.push([entry.link[0].href.substr(32, 11), entry.title.$t]);
      });

      console.log("video_ids:");
      console.log(video_ids);
      sendPrivateMessage(uuid, "youtube_results", {"video_ids": video_ids.slice(0,9)});   
      
    });
  });
}

function search_soundcloud(query, uuid) {
  var body = '';
  var path = '/tracks?q=' + escape(query) + '&format=json&client_id=' + settings.SOUNDCLOUD_CLIENT_ID; 
  console.log(path);


  http.get( {
    host: 'api.soundcloud.com',
    path: '/tracks?q=' + escape(query) + '&format=json&client_id=' + settings.SOUNDCLOUD_CLIENT_ID, 
    method: 'GET'
  }, function(response) {
    response.setEncoding('utf8');
    response.on( 'error', fail );
    response.on( 'data', function (chunk) {
        if (chunk) body += chunk;
    });
    response.on( 'end', function () {

      console.log(body);
      var entries = JSON.parse(body), 
          song_ids = [];

      entries.forEach( function(entry) {
        song_ids.push([entry.id, entry.title]);
      });

      console.log("song_ids:");
      console.log(song_ids);
      sendPrivateMessage(uuid, "soundcloud_results", {"song_ids": song_ids.slice(0,9)});   
      
    });
  });
}
