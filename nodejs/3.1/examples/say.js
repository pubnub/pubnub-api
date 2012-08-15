/* ---------------------------------------------------------------------------
    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys
--------------------------------------------------------------------------- */
var pubnub = require("./../pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
})
,   exec  = require('child_process').exec;

pubnub.subscribe({
    channel  : "my_channel",
    connect  : function() {
        // Publish a Message on Connect
        pubnub.publish({
            channel  : "my_channel",
            message  : { text : 'Ready to Receive Voice Script.' }
        });
    },
    callback : function(message) {
        console.log(message);
        exec('say ' + (
            'voice' in message &&
            message.voice ? '-v ' +
            message.voice + ' ' : ''
        ) + message.text);

    },
    error : function() {
        console.log("Network Connection Dropped");
    }
});
