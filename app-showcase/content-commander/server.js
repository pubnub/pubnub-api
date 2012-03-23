var flatiron = require('flatiron');
var path = require('path');
var plates = require('plates');
var fs = require('fs');
var ecstatic = require('ecstatic');

var app = flatiron.app;
app.config.file({ file: path.join(__dirname, 'config', 'config.json') });
app.use(flatiron.plugins.http);

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

app.router.get('/director', function () {
  console.log('/director');
  var flat = this;
  fs.readFile('director.html', function(err, buffer) {
    //console.log(file);
    var html = buffer.toString();
    var data = { "test": "New Value" };
    var output = plates.bind(html, data); 

    flat.res.writeHead(200, { 'Content-Type': 'text/html' });
    flat.res.end(output);
  });
});


app.http.before = [
  ecstatic(__dirname + '/media', {autoIndex: false})
];

var PORT = 3000;
app.start(PORT);
console.log('BOOM port ' + PORT);

