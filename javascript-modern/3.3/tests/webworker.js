(function(){

    "use strict"

    importScripts('../pubnub-3.3-common.js')
    importScripts('../pubnub-3.3.js')

    var app = PUBNUB({
        publish_key   : 'demo',
        subscribe_key : 'demo'
    });
    var channel = 'webworker-test-channel' + '-' + app.uuid();
    app.publish({
        channel  : channel,
        message  : 'It Works!',
        callback : function(info) {
            postMessage(info);
            app.history({
                channel  : channel,
                limit    : 1,
                message  : 123,
                callback : postMessage
            });
            app.detailedHistory({
                channel  : channel,
                count    : 1,
                message  : 123,
                callback : postMessage
            })
        }
    });
    app.subscribe({
        channel  : channel,
        connect  : function() {
            
            setTimeout(function(){ 
                app.here_now({
                    channel  : channel,
                    callback : postMessage  
                })}, 5000);
           
            setTimeout(function(){ 
                app.publish({
                    channel  : channel,
                    message  : "Subscribe Test Message",
                    callback :  postMessage 
                })}, 5000);
        }, 
        callback : function(response) { postMessage(response); }
    })

})();
