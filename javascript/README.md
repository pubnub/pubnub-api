# YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

## TESTLING - (OPTIONAL)
PubNub JavaScript API for Web Browsers
uses Testling Cloud Service for QA and Deployment.
http://www.testling.com/

You need this to run './test.sh' unit test.
This is completely optional, however we love Testling.


## PubNub 3.1 Real-time Cloud Push API - JAVASCRIPT
http://www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/tutorial/javascript-push-api

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

## SIMPLE EXAMPLE USE PUBNUB API
```html
<div id=pubnub></div>
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js ></script>
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
<div id=pubnub></div>
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js ></script>
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
        }
    })
})();</script>
```
