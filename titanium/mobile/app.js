Ti.include('pubnub.js');

(function(){

    // ----------------------------------
    // INIT PUBNUB
    // ----------------------------------
    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo',
        ssl           : false,
        origin        : 'pubsub.pubnub.com'
    });

    // ----------------------------------
    // LISTEN FOR MESSAGES
    // ----------------------------------
    pubnub.subscribe({
        channel  : 'test',
        callback : function(message) {
            // Message RECEIVED!
            Ti.API.log(JSON.stringify(message));
        },
        error : function() {
            // The internet is gone.
            Ti.API.log("Connection Lost");
        }
    });

    // ----------------------------------
    // SEND MESSAGE
    // ----------------------------------
    setInterval( function() {
        pubnub.publish({
            channel  : 'test',
            message  : { example : "Hello World!" },
            callback : function(info) {
                if (info[0])
                    Ti.API.log("Successfully Sent Message!");
                else
                    // The internet is gone.
                    Ti.API.log("Failed! -> " + info[1]);
            }
        });
    }, 1000 );

})();
