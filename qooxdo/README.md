# YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

## PubNub 3.3 Real-time Cloud Push API - qooxdoo integration with base JavaScript Client
http://www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/tutorial/javascript-push-api

## Run 3.3/custom/source/index.html from your browser to check it out!

This is a simple demo that integrates qooxdoo with PubNub JavaScript client.
Refer to the complete JavaScript client documentation and examples here:

https://github.com/pubnub/pubnub-api/tree/master/javascript

## Notes

The only real tweaks that had to be made were based on the questions and comments made by Hristo Hristov, and ThomasH
on the stackoverflow thread: http://stackoverflow.com/questions/12405175/how-to-integrate-qooxdoo-and-pubnub

Those the final result of those tweaks can be found in config.json, and they look like this:

```javascript
    "jobs" : {
        "add-pubnub" : {
            "add-script" : [
                {
                    "uri": "http://cdn.pubnub.com/pubnub-3.3.min.js"
                }
            ]
        },
        "source-script" : {
            "extend" : ["add-pubnub"]
        },
        "build-script" : {
            "extend" : ["add-pubnub"]
        }
    }
```

```
./generate.py source
```

compiles it, and away we go. Please post any suggestions, questions, or comments!