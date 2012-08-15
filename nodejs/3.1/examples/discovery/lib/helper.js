
var uuid = require('./../lib/uuid.js'),
    discovery = require('./discovery.js');

module.exports.getServiceChannel = function(server, name, callback) {
    var client_channel = uuid().toString();

    server.subscribe({
        channel  : client_channel,
        callback : function(message) {            
            if ((!message) || (!message.responseSet)) return callback(message.errorSet, null)
                else return callback(null, message.responseSet);
        }
    });
    
    server.publish({
        channel : discovery.channel,
        message : {
            clientChannel: client_channel,
            requestSet: {
                op: "get",
                name: name
            }
        }
    })
}

module.exports.getServiceList = function(server, callback) {
    var client_channel = uuid().toString();

    server.subscribe({
        channel  : client_channel,
        callback : function(message) {
            if ((! message) || (! message.responseSet)) return callback(message.errorSet, null)
                else return callback(null, message.responseSet);
        }
    });
    
    server.publish({
        channel : discovery.channel,
        message : {
            clientChannel: client_channel,
            requestSet: {
                op: "list"
            }
        }
    })
}


module.exports.getServiceChannel = function(server, name, callback) {    
    var client_channel = uuid().toString();

    server.subscribe({
        channel  : client_channel,
        callback : function(message) {            
            if ((!message) || (!message.responseSet)) return callback(message.errorSet, null)
                else return callback(null, message.responseSet);
        }
    });
    
    server.publish({
        channel : discovery.channel,
        message : {
            clientChannel: client_channel,
            requestSet: {
                op: "get",
                name: name
            }
        }
    })
}

    
module.exports.registryServiceChannel = function(server, name, channel) {
    server.publish({
        channel : discovery.channel,
        message : {
            requestSet:{                
                op: 'set',
                name: name,
                channel: channel
            }
        }
    })
};

module.exports.unregistryServiceChannel = function(server, name, channel) {    
    server.publish({
        channel : discovery.channel,
        message : {
            requestSet:{                
                op: 'del',
                name: name,
                channel: channel
            }
        }
    })
};



module.exports.query = function(server, service, request, callback) {
    var client_channel = uuid().toString();

    server.subscribe({
        channel  : client_channel,
        callback : function(response) {
            return callback(response);
        }
    });

    this.getServiceChannel(server, service, function(err, channel) {
        if (err) throw err;
        server.publish({
            channel : channel,
            message : {
                clientChannel: client_channel,
                requestSet: request
            }
        });
    });
};


