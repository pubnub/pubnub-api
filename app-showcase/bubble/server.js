var http = require('http');
var fs = require("fs");
var url = require("url");
var express = require("express");
var jade = require('jade');
var mime = require("mime");


var app = express.createServer()


app.configure(function() {
  app.use(app.router);
});

app.configure("development", function() {
  global.ENV = "development";
  global.PORT = 8888;
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
  render_page('main', res, {});
});

app.get('/webgl', function(req, res) {
  console.log('/webgl');
  load_page('/templates/webgl.html', res);
});

app.get('/*', function(req, res) {
  var path = escape(url.parse(req.url).pathname);
  console.log(path);
  if (path.split("/")[1] == "media") {
    load_page(path, res);
  }
  else 
    send_404(res);
});

var render_page = function(template_name, res, context) {
  template_path = './templates/' + template_name + '.jade'
  options = { locals: context }
  if (global.ENV == "development") {
    options['compileDebug'] = true;     
    options['inline'] = false;     
  }
  jade.renderFile(template_path, options, function(err, html) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end(html);
  });
};

var load_page = function(path, res ){
  fs.readFile(__dirname + path, function(err, data){
    if (err) {
      return send_404(res);
    }
    content_type = mime.lookup(path)

    res.writeHead(200,{ 'Content-Type': content_type })
    res.write(data, 'utf8');
    res.end();
  });
};

send_404 = function(res){
  console.log("  (404)");
  render_page('404', res, {});
};


console.log('Port ' + global.PORT);



