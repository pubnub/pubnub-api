#!/usr/bin/env node

var helper = require('./../lib/helper.js');

var pubnub = require("./../lib/pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
});


helper.query(pubnub, 'time', null, function(response) {
    if (response) {
        if (response.responseSet)
            console.log("response: " + response.responseSet);
        if (response.errorSet)
            console.log("error: " + response.responseSet);
    }
    process.exit();
});





