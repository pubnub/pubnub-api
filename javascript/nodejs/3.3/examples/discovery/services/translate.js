

var querystring = require('querystring'),
    http = require('http');

function translate(config) {
    this.config = config;
}

translate.prototype.onStart = function(callback) {    
    return callback();
}

translate.prototype.onStop = function(callback) {
    return callback();
}

translate.prototype.onTick = function(callback) {
    return callback();
}

translate.prototype.onReceipt = function(message, callback) {    
    var args = {
        appId: message.appId,
        from: message.from,
        to: message.to,
        text: message.text
    };
    
    var options = {
        host: 'api.microsofttranslator.com',
        path: '/V2/Ajax.svc/Translate?' + querystring.stringify(args)
    };
    
    http.request(options, function(response) {
        var str = '';
        
        response.on('data',
                    function (chunk) {
                        str += chunk;
                        }
        );
        
        response.on('end',
                    function () {
                        return callback(null, str.substring(2, str.length - 1));
                    }
        );
    }).end();
}

module.exports = function(config) { return new translate(config); }
