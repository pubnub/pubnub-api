

function discovery(config) {
    this.config = config;
    this.db = {};
}

discovery.prototype.onStart = function(callback) {
    return callback();
}

discovery.prototype.onStop = function(callback) {
    return callback();
}

discovery.prototype.onTick = function(callback) {
    return callback();
}

discovery.prototype.onReceipt = function(message, callback) {
    try {
        switch (message.op) {        
            case 'set':
                if (!this.db[message.name]) {
                    this.db[message.name] = [];                
                }
                this.db[message.name].push(message.channel);
                console.log('%s\tnew %s service instance is registered.', new Date().toTimeString(), message.name);                
                return callback;
                
            case 'get':
                if ((this.db[message.name]) && (this.db[message.name].length > 0)) {
                   console.log('%s\tprocessed a search request for %s service.', new Date().toTimeString(), message.name);                
                   var ctrl = this.db[message.name].shift();
                   this.db[message.name].push(ctrl);
                   return callback(null, ctrl)
                }           
                return callback(util.format("service %s isn't found", message.name), null);
                
            case 'list':
                var list = [];
                for(var name in this.db) {
                    list.push(name);
                }            
                return callback(null, { list: list });
                
            case 'del':                
                var channels = this.db[message.name];                
                for (var i = 0; i < channels.length; i++) {
                    if (channels[i] == message.channel) {
                        console.log('%s\tprocessed a delete request for %s service.', new Date().toTimeString(), message.name);                        
                        channels.splice(i, 1);                        
                        if (channels.length == 0) 
                            delete this.db[message.name];                        
                        return callback();                                
                    }
                }
        }
    }
    catch (ex) {
        return callback(ex, null);
    }
    return callback();
}

module.exports = function(config) { return new discovery(config); }
