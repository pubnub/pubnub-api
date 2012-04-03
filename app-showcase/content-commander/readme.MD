Content Commander
=================

A simple demo to show PubNub's ablity to push arbitrary HTML. 
 
Running via node.js
-------------------

1. get [node.js](http://nodejs.org)
2. cd into directory
3. run `npm install`
4. create `settings.js` file with the following lines: 

        exports.PUBNUB_PUBLISH_KEY = "insert your publish key from pubnub here"; 
        exports.PUBNUB_SUBSCRIBE_KEY = "insert your subscribe key from pubnub here";
        exports.PUBNUB_SECRET_KEY = "insert your secret key from pubnub here";
        exports.SOUNDCLOUD_CLIENT_ID = "for soundcloud functionality, insert soundcloud api id here"; 
        exports.FLICKR_KEY = "for flickr functionality key, insert flickr api key here";

5. run `node server.js`
6. navigate to `http://localhost:3000/commander`




