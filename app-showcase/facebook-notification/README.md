# PubNub Facebook Notification

This is an example of a Facebook-like
Window Box that notifies your user with a custom message via PubNub.
You can send updates to your users on their Mobile Phone or Browser.
This will show your user a notification; any notification you.

Using PubNub allows Data Push via WebSockets, BOSH, Comet and other Mechanisms
to be used in your application providing you the ability to send data
**AT ANY TIME** directly to your users via **MASS BROADCAST** or
**INDIVIDUAL NOTIFICATIONS**.

## Start Here: Live Demo

Try it Now: [http://pubnub-demo.s3.amazonaws.com/facebook-notification/index.html](http://pubnub-demo.s3.amazonaws.com/facebook-notification/index.html)

Begin here for easy copy/paste of code.
It is very easy to get started and we recommend you start
with the example link above before you begin.

#### Setup Your Page

First include the **FBootstrap** resources in order to provide the 
look and feel of the notification window.
Add these Styles to your HTML file.

```html
<link href=bootstrap.css rel=stylesheet>
<style type=text/css> body { padding-top: 60px; } </style>
```

#### Data Connection Code

Next you need to setup a PubNub Data Connection and then
add rules for what to do with the data once it is received.

```html
<script src=https://pubnub.s3.amazonaws.com/pubnub-3.1.min.js></script>
<script src=http://code.jquery.com/jquery-1.5.2.min.js></script>
<script src=bootstrap-modal.js></script>
<script>(function(){

    // PubNub (For Data Push to User)
    var pubnub = PUBNUB.init({
        subscribe_key : 'demo',
        ssl           : false
    });

    // Setup New Data Push Connectoin via PubNub
    pubnub.subscribe({
        restore  : true,
        channel  : 'example-user-id-1234',
        callback : show_notification
    });

    // Setup Alert Window
    $('#new-alert').modal({ keyboard : true });

    // Show the Notification Window
    function show_notification(message) {
        $('#new-alert').modal('show');
    }

    // Simulate Notification
    $('#simulate-notification').bind( 'mousedown', function() {
        pubnub.publish({
            channel : 'example-user-id-1234',
            message : 'alert'
        });
        return false;
    } );

})();</script>
```

#### Python Push Example

Next you will want to add this `python` code
to your Django or any other framework.
You can add this to the `message post` code in your app.
This will post a notification to your user.
This specific example will cause a notification to appear
inside the Facebook Notification page.

```python
## PubNub Setup
from Pubnub import Pubnub
pubnub = Pubnub( 'demo', 'demo', None, False )

## Push Notice to 'example-user-id-1234'
info = pubnub.publish({
    'channel' : 'example-user-id-1234',
    'message' : { 'your-data' : 'any-data-here' }
})
print(info)
```
