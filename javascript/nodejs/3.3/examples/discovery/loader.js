#!/usr/bin/env node

var colors = require('colors'),
    fs = require('fs'),
    util = require('util'),
    uuid = require('./lib/uuid'),
    helper = require('./lib/helper'),
    pubnub = require('./lib/pubnub.js'),
    discovery = require('./lib/discovery.js');


// loading configuration
var config = JSON.parse(fs.readFileSync('./config.json'));

// initalize connect to pubnub
var server = pubnub.init(config.pubnub);

var obj_list = [];
var obj_channel = [];

// create controllers list
var service_list = process.argv.slice(2);    
if ((!service_list) || (!service_list.length)) {
    service_list = ['ip', 'echo', 'time', 'translate'];
}

// load controllers
service_list.forEach(function(name) {
    var err;    
    try {
        obj_list.push(require(util.format('./services/%s.js', name))(config));
    } catch (ex) {
        err = ex;
    }
    console.log('%s\tloading %s service ...\t[%s]', new Date().toTimeString(), name, err ? 'Fail'.red: 'Ok'.green);
});

// start, registry and subscribe controllers
obj_list.forEach(function(obj, index) {    
    if (typeof obj.onStart == 'function') {
            obj.onStart(function(err) {
                console.log('%s\tstarting %s service ...\t[%s]', new Date().toTimeString(), service_list[index], err ? 'Fail'.red: 'Ok'.green);                
                if (typeof obj.onReceipt == 'function') {                    
                    // generate channel name. discovery is a entrypoint for all solution.                   
                    obj_channel[index] =
                        service_list[index] ==
                            'discovery' ?
                                discovery.channel : uuid().toString();
                            
                    // send infomation to discovery service
                    helper.registryServiceChannel(server, service_list[index], obj_channel[index]);
                    
                    // subscribe service
                    server.subscribe({
                        channel  : obj_channel[index],
                        callback :
                            function(request) {
                                obj.onReceipt(request.requestSet, function(err, response) {
                                        if (request.clientChannel) {
                                            server.publish({
                                                channel: request.clientChannel,
                                                message: ( err ? { errorSet: err } : { responseSet: response } )
                                            })
                                        }
                                })
                            }                
                    });        
                }
            })
    }
});

console.log('For exit press ctrl^c...');

// if need initialize timer
if (config.interval > 0) {
    setInterval(
        function() {    
            obj_list.forEach(function(obj, index) {
                if (typeof obj.onTick == 'function')
                        obj.onTick(function(err) {});
            })
        },
        config.interval
    );
}


// correct exit
process.on('exit', function () {    
    obj_list.forEach(function(obj, index) {
        helper.unregistryServiceChannel(server, service_list[index], obj_channel[index]);
        if (typeof obj.onStop == 'function') {
                obj.onStop(function(err) {
                    console.log('%s\tstopping %s service ...\t[%s]', new Date().toTimeString(), service_list[index], err ? 'Fail'.red: 'Ok'.green);
                })
        }
    });
    
    setTimeout(function() {
        process.exit();
    }, config.delayBeforeShutdown);

});

// correct exit
process.on('SIGINT', function () {    
    obj_list.forEach(function(obj, index) {
        helper.unregistryServiceChannel(server, service_list[index], obj_channel[index]);
        if (typeof obj.onStop == 'function') {
                obj.onStop(function(err) {
                    console.log('%s\tstopping %s service ...\t[%s]', new Date().toTimeString(), service_list[index], err ? 'Fail'.red: 'Ok'.green);
                })
        }            
    });
    
    setTimeout(function() {
        process.exit();
    }, config.delayBeforeShutdown);
});


// incorrect exit
process.on('uncaughtException', function (err) {
    helper.unregistryServiceChannel(server, service_list[index], obj_channel[index]);
    obj_list.forEach(function(obj, index) {        
        if (typeof obj.onStop == 'function') {
                obj.onStop(function(err) {
                    console.log('%s\tstopping %s service ...\t[%s]', new Date().toTimeString(), service_list[index], err ? 'Fail'.red: 'Ok'.green);
                })
        }
    });
    
    setTimeout(function() {
        process.exit();
    }, config.delayBeforeShutdown);
});
