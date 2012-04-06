

function echo(config) {
    this.config = config;
}

echo.prototype.onStart = function(callback) {    
    return callback();
}

echo.prototype.onStop = function(callback) {    
    return callback();
}

echo.prototype.onTick = function(callback) {
    return callback();
}

echo.prototype.onReceipt = function(message, callback) {    
    return callback(null, message);
}

module.exports = function(config) { return new echo(config); }
