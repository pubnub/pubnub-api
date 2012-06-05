(function(){

    "use strict"

    importScripts('../pubnub-3.1.js')

    var app = PUBNUB({
        publish_key   : 'demo',
        subscribe_key : 'demo'
    })

    app.publish({
        channel  : 'my_channel',
        message  : 'It Works!',
        callback : function(info) {
            postMessage(info)
            app.history({
                channel  : 'my_channel',
                limit    : 1,
                message  : 123,
                callback : postMessage
            })
        }
    })

})();
