

function time(config) {
    this.config = config;
}

time.prototype.onStart = function(callback) {    
    return callback();
}

time.prototype.onStop = function(callback) {
    return callback();
}

time.prototype.onTick = function(callback) {
    return callback();
}

time.prototype.onReceipt = function(message, callback) {
    return callback(null, new Date().toUTCString());
}

module.exports = function(config) { return new time(config); }
