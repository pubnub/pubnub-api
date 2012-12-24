# YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

## TESTLING - (OPTIONAL)
PubNub JavaScript API for Web Browsers
uses Testling Cloud Service for QA and Deployment.
http://www.testling.com/

You need this to run './test.sh' unit test.
This is completely optional, however we love Testling.


## PubNub 3.3.1 Real-time Cloud Push API - JAVASCRIPT
http://www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/tutorial/javascript-push-api

PubNub is a blazingly fast cloud-hosted messaging service for building
real-time web and mobile apps. Hundreds of apps and thousands of developers
rely on PubNub for delivering human-perceptive real-time
experiences that scale to millions of users worldwide. PubNub delivers
the infrastructure needed to build amazing MMO games, social apps,
business collaborative solutions, and more.

## SIMPLE EXAMPLE
```html
<div id=pubnub pub-key=demo sub-key=demo></div>
<script src=http://cdn.pubnub.com/pubnub-3.3.1.min.js ></script>
<script>

    // LISTEN
    PUBNUB.subscribe({
        channel  : "hello_world",
        callback : alert
    })

    // SEND
    PUBNUB.publish({
        channel : "hello_world",
        message : "Hi."
    })

</script>
```

## ADVANCED STYLE
```html
<div id=pubnub pub-key=demo sub-key=demo></div>
<script src=http://pubnub.s3.amazonaws.com/pubnub-3.3.1.min.js ></script>
<script>(function(){
    // LISTEN FOR MESSAGES
    PUBNUB.subscribe({
        channel    : "hello_world",      // CONNECT TO THIS CHANNEL.
        restore    : false,              // STAY CONNECTED, EVEN WHEN BROWSER IS CLOSED
                                         // OR WHEN PAGE CHANGES.
        callback   : function(message) { // RECEIVED A MESSAGE.
            alert(message)
        },
        connect    : function() {        // CONNECTION ESTABLISHED.
            PUBNUB.publish({             // SEND A MESSAGE.
                channel : "hello_world",
                message : "Hi from PubNub."
            })
        },
        disconnect : function() {        // LOST CONNECTION.
            alert(
                "Connection Lost." +
                "Will auto-reconnect when Online."
            )
        },
        reconnect  : function() {        // CONNECTION RESTORED.
            alert("And we're Back!")
        },
        presence   : function(message) { // Presence() example (see console for logged output.)
            console.log(message, true);
        }
    })
})();

</script>

<span onclick="hereNow()">Click Me for Here Now!</span> // here_now() example (see console for logged output.)
 <br/>
<span onclick="history()">Click Me for History!</span> // detailedHistory() example (see console for logged output.)

<script type="text/javascript">

    function hereNow() {
        PUBNUB.here_now({channel:'hello_world', callback:function (message) {
            console.log(message);
        }});
    }

    function history() {
        PUBNUB.detailedHistory({count:10, channel:'hello_world', callback:function (message) {
            console.log(message);
        }});
}


</script>

```

## SSL MODE

```html
<div id=pubnub ssl=on></div>
<script src=https://pubnub.a.ssl.fastly.net/pubnub-3.3.1.min.js></script>
<script>(function(){

    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo',
        origin        : 'pubsub.pubnub.com',
        ssl           : true
    });

    pubnub.subscribe({
        channel  : 'my_channel',
        connect  : function() { /* ... */ },
        callback : function(message) {
            alert(JSON.stringify(message));
        }
    });

})();</script>
```

## Using the PUBNUB init() Function

Sometimes you want to use create a PubNub Instance directly in JavaScript
and pass the PubNub API Keys without using a DOM element.
To do this, simply follow this `init` example:

```html
<script src=http://cdn.pubnub.com/pubnub-3.3.1.min.js ></script>
<script>(function(){

    // INIT PubNub
    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo',
        origin        : 'pubsub.pubnub.com'
    });

    // LISTEN
    pubnub.subscribe({ channel  : "hello_world", callback : alert })

    // SEND
    pubnub.publish({ channel : "hello_world", message : "Hi." })

})();</script>
```