/* ---------------------------------------------------------------------------

    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys

--------------------------------------------------------------------------- */
var pubnub  = require("./../pubnub.js");
var channel = 'my_channel';
var network = pubnub.init({
    publish_key   : "demo",
    subscribe_key : "demo"
});

/* ---------------------------------------------------------------------------
Print All
--------------------------------------------------------------------------- */
get_all_history({
    channel  : channel,
    callback : function(messages) {
        console.log(messages);
    }
})

/* ---------------------------------------------------------------------------
Get All History Message for a CHANNEL
--------------------------------------------------------------------------- */
function get_all_history(args) {
    var channel  = args['channel']
    ,   callback = args['callback']
    ,   start    = 0
    ,   history  = [];

    (function add_messages() {
        network.detailedHistory({
            channel  : channel,
            start    : start,
            reverse  : true,
            callback : function(messages) {
                var msgs = messages[0]
                ,   end  = start = messages[2];

                if (!msgs.length) return callback(history);

                history = history.concat(msgs);
                add_messages();
            }
        });
    })();
}
