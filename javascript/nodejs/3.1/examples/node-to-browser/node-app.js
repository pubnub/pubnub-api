/* ---------------------------------------------------------------------------

    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys

--------------------------------------------------------------------------- */
console.log('Broadcasting Messages from Node...');
require('child_process').exec('open index.html');

var pubnub = require("./../../pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
});

/* ---------------------------------------------------------------------------
Listen for Messages
--------------------------------------------------------------------------- */
pubnub.subscribe({
    channel  : "my_node_channel",
    callback : function(message) {
        console.log( "Message From Browser - ", message );
    }
});

/* ---------------------------------------------------------------------------
Type Console Message
--------------------------------------------------------------------------- */
setInterval( function() {
    pubnub.publish({
        channel : "my_browser_channel",
        message : 'Hello from Node!'
    });
}, 1000 );

