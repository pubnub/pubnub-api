## ------------------------------------------------------
##
## (FREE VERSION) USE "demo" KEYS As Shown Below
##
## (PAID VERSION) GET YOUR OWN API KEYS:
## http://www.pubnub.com/account
##
## ------------------------------------------------------

## ------------------------------------------------------
## ALERT!!! ANDROID FIX!!!
## ------------------------------------------------------
## 
## You must update the tiapp.xml and add the following:
## 
## <property name="ti.android.threadstacksize" type="int">327680</property>
## 
## ------------------------------------------------------

## ----------------------------------------------------------------
## PubNub 3.1 Real-time Cloud Push API - JAVASCRIPT TITANIUM MOBILE
## ----------------------------------------------------------------
##
## www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
## http://www.pubnub.com/tutorial/javascript-push-api
##
## PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
## This is a cloud-based service for broadcasting Real-time messages
## to millions of web and mobile clients simultaneously.


/* ====================================================== */
/* SIMPLE EXAMPLE USE PUBNUB API (ADVANCED EXAMPLE BELOW) */
/* ====================================================== */

Ti.include('pubnub.js');

// ----------------------------------
// INIT PUBNUB
// ----------------------------------
var pubnub = PUBNUB.init({
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false,
    origin        : 'pubsub.pubnub.com'
});


// -------------------
// LISTEN FOR MESSAGES
// -------------------
pubnub.subscribe({
    channel  : "hello_world",
    callback : function(message) { Ti.API.log(message) }
})

// ------------
// SEND MESSAGE
// ------------
pubnub.publish({
    channel : "hello_world",
    message : "Hi."
})

/* =============================== */
/* ADVANCED EXAMPLE USE PUBNUB API */
/* =============================== */

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

