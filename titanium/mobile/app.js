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
        connect  : function() {
            // You can Receive Messages!
            send_a_message("Hello World! #1");
            send_a_message("Hello World! #2");
            send_a_message("Hello World! #3");
        },
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
    function send_a_message(message) {
        pubnub.publish({
            channel  : 'test',
            message  : { example : message },
            callback : function(info) {
                if (info[0])  Ti.API.log("Successfully Sent Message!");
                if (!info[0]) Ti.API.log("Failed Because: " + info[1]);
            }
        });
    }

})();
