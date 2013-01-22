#!/usr/bin/env node

var helper = require('./../lib/helper.js');

var pubnub = require("./../lib/pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
});

var request = {
    "ip": "209.85.148.100"
};

helper.query(pubnub, 'ip', request, function(response) {
    if (response) {
        if (response.responseSet)
            console.log("%s -> %s - %s\t%s (%s)",
                        request.ip, response.responseSet.startIp,response.responseSet.stopIp,
                            response.responseSet.code,response.responseSet.country);
        if (response.errorSet)
            console.log("error: " + response.responseSet);
    }
    process.exit();
});





