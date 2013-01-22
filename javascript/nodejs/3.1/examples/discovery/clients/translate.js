#!/usr/bin/env node

var helper = require('./../lib/helper.js');

var pubnub = require("./../lib/pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
});

var request = {
    "appId": "E7A859ECBE5107A9C7DF91B1B450F6096212ED7B",
    "from": "en",
    "to": "it",
    "text": "I'll be back."
};

helper.query(pubnub, 'translate', request, function(response) {
    if (response) {
        if (response.responseSet)
            console.log("response: %s -> %s", request.to, response.responseSet);
        if (response.errorSet)
            console.log("error: " + response.responseSet);
    }
    process.exit();
});





