/* ---------------------------------------------------------------------------

    Run Example:

        node example-usage.js

    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys

--------------------------------------------------------------------------- */
var pubnub  = require("./pubnub.js");
var network = pubnub.init({
    publish_key   : "demo",
    subscribe_key : "demo",
    secret_key    : "",
    ssl           : false,
    origin        : "pubsub.pubnub.com"
});

/* ---------------------------------------------------------------------------
Listen for Messages
--------------------------------------------------------------------------- */
network.subscribe({
    channel  : "hello_world",
    callback : function(message) {
        console.log(message);
    },
    error    : function() {
        console.log("Network Connection Dropped");
    }
});

/* ---------------------------------------------------------------------------
Send Messages (1 Message Per Second for testing)
--------------------------------------------------------------------------- */
var delivery_count = 0;
var crazy          = ' ~`!@#$%^&*(顶顅Ȓ)+=[]\\{}|;\':",./<>?abcd'
setInterval( function() {
    network.publish({
        channel  : "hello_world",
        message  : {
            count    : ++delivery_count,
            some_key : "Hello World!",
            crazy    : crazy
        },
        callback : function(info){
            if (!info[0]) {
                console.log("Failed Message Delivery")
            }
            console.log(info);
        }
    });
}, 1000 );

/* ---------------------------------------------------------------------------
Get Channel History
--------------------------------------------------------------------------- */
network.history({
    channel  : "hello_world",
    limit    : 10,
    callback : function(messages){
        // messages is an array of history.
        console.log(messages);
    }
});

/* ---------------------------------------------------------------------------
Utility Function Returns PubNub TimeToken
--------------------------------------------------------------------------- */
network.time(function(time){
    console.log(time);
});
