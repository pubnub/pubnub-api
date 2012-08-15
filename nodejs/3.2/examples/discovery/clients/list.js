#!/usr/bin/env node

var uuid = require('./../lib/uuid.js'),
    helper = require('./../lib/helper.js');

var pubnub = require("./../lib/pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
});



helper.getServiceList(pubnub, function(err, services) {
    if (!err) {
        for(var i = 0; i < services.list.length; i++) {
            console.log(services.list[i]);            
        }
        process.exit();
    }
});






