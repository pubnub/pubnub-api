/* ---------------------------------------------------------------------------

    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys

--------------------------------------------------------------------------- */
var pubnub  = require("./../pubnub.js");
//var channel = 'c7f3bd82-7c29-4c84-8a6f-e4e1fe9fef0d';
var channel = 'abcdefg';
var network = pubnub.init({
    publish_key   : "demo",
    subscribe_key : "sub-c-632b3351-cae8-11e1-8f60-a51bd8a943ce" // SANDBOX
    //subscribe_key : "sub-7ccb579e-0ce0-11e2-b7c5-a7b30513cafb"   // SANDBOX
    //subscribe_key : "sub-c-b58d8521-cb1b-11e1-9228-09dd9d19e0cf" // SANDBOX
    //subscribe_key : "sub-48ccb959-711a-11e0-960e-d15a8ef09405"   // GALAXY
    //subscribe_key : "sub-61872fab-21ef-11e2-8ac0-0f7856463c9a"   // ??
    //subscribe_key : ""
    //subscribe_key : ""
});
//http://pubsub.pubnub.com/publish///0//0/%7B%22v%22%3A1%2C%22ts%22%3A1356705541502%2C%22data%22%3A%7B%22g%22%3A%22fd118f13-43ea-4f4f-a8c1-0d0daf64786e%22%2C%22u%22%3A%22jason%22%2C%22t%22%3A%22u%22%2C%22p%22%3A%22http%3A%2F%2Fd376spluvo6k9w.cloudfront.net%2Fprofile_photo%2Ffd118f13-43ea-4f4f-a8c1-0d0daf64786e_1327279585707.png%22%2C%22m%22%3A%22Test%22%2C%22k%22%3A%221%22%2C%22i%22%3A4%7D%7D

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

                history = history.concat(msgs);

                if (msgs.length < 100) return callback(history);

                add_messages();
            }
        });
    })();
}
