var fs = require('fs');

function ip(config) {
    var self = this;
    
    self.config = config;    
    self.db = {};
    self.cache = {};
}

ip.prototype.onStart = function(callback) {
    var self = this;
    
    fs.readFile(self.config.ipdb, 'utf8', function (err,data) {
            if (err) console.log(err)
            else {                
                    var lines = data.split('\n');			
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i] != "") {                            
                            var fields = lines[i].split(',');
                            
                            for(var j = 0; j < fields.length; j++)
                                fields[j] = fields[j].slice(1,-1);                            
                                                
                            var ip1 = fields[0].split('.');			    
                            var ip2 = fields[1].split('.');

                            var link = self.db;
                            for(var k = 0; k < ip1.length; k++) {
                                if (ip1[k] == ip2[k]) {
                                        if (!link[ip1[k]]) link[ip1[k]] = {};
                                        link = link[ip1[k]];
                                } else {					    
                                        link[ip1[k] + "-" + ip2[k]] = {                                            
                                            startIp:    fields[0],
                                            stopIp:     fields[1],
                                            startNum:   fields[2],
                                            stopNum:    fields[3],                                                
                                            code:       fields[4],
                                            country:    fields[5]                                            
                                        }
                                        link = link[ip1[k] + "-" + ip2[k]];
                                }
                            }
                        }
                    }            
            }
        return callback();    
    });	    
}

ip.prototype.onStop = function(callback) {    
    return callback();
}

ip.prototype.onTick = function(callback) {
    return callback();
}

ip.prototype.onReceipt = function(message, callback) {
    var self = this;
    
    if (! message.ip)
        return callback("ip parameter is not found");            
    
    if (self.cache[message.ip])
        return callback(null, self.cache[message.ip]);
    
    var ip = message.ip.split('.');
            
    var link = self.db;
    
    for (var i = 0; i < ip.length; i++) {
        if (link.startIp) {
            self.cache[message.ip] = link;
            return callback(null, link);
        }
        if (link[ip[i]]) {
            link = link[ip[i]];
        } else {            
            var found = false;            
            for(var name in link) {                
                if (name.indexOf('-') >= 0) {
                    var val = name.split('-');
                    found = (parseInt(ip[i]) >= parseInt(val[0])) && (parseInt(ip[i]) <= parseInt(val[1]));
                    if (found) {
                        link = link[name];
                        break;
                    }
                }
            }
            if (! found) return callback("location is not found");            
        }
    }
    if (link.startIp) {
        self.cache[message.ip] = link;
        return callback(null, link);
    }
}

module.exports = function(config) { return new ip(config); }










