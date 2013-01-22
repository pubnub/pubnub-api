# PubNub HTML5 Modern JavaScript Library

For a faster PubNub load, use the PubNub HTML5 Modern JavaScript
Library which is `CommonJS` and HTML5 `WebWorker` Ready.

#### Supported Browsers:

 - firefox/3.6'
 - firefox/9.0'
 - firefox/10.0'
 - chrome/16.0'
 - chrome/17.0'
 - iexplore/9.0'
 - safari/5.1'

```html
<script src=pubnub-3.3.js></script>
<script>(function(){
    // ----------------------------------
    // INIT PUBNUB
    // ----------------------------------
    var pubnub = PUBNUB({
        publish_key   : 'PUBLISH_KEY_HERE',
        subscribe_key : 'SUBSCRIBE_KEY_HERE',
        ssl           : false,
        origin        : 'pubsub.pubnub.com'
    });

    // ----------------------------------
    // LISTEN FOR MESSAGES
    // ----------------------------------
    pubnub.subscribe({
        restore  : true,
        connect  : send_hello,
        channel  : 'my_channel',
        callback : function(message) {
            console.log(JSON.stringify(message));
        },
        disconnect : function() {
            console.log("Connection Lost");
        }
    });

    // ----------------------------------
    // SEND MESSAGE
    // ----------------------------------
    function send_hello() {
        pubnub.publish({
            channel  : 'my_channel',
            message  : { example : "Hello World!" },
            callback : function(info) {
                console.log(JSON.stringify(info));
            }
        });
    }
})();</script>

```

