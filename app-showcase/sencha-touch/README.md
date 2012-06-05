Sencha Touch + PubNub
=====================

Here is a simple chat example of PubNub and Sencha Touch working together.
Live demo [here](http://pubnub.s3.amazonaws.com/sencha-touch/index.html)


The PubNub minified javascript library is included in `/resources/js` and added to the project in `app.json` like this: 

    {
        "path": "resources/js/pubnub-3.1.min.js"
    },

Then, in app.js, in launch(), add this:  
```
    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo',
        ssl           : false,
        origin        : 'pubsub.pubnub.com'
    });
```


You now have the full power of PubNub in your Sencha Touch apps!

       


