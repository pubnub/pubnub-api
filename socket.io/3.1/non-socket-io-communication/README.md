# Sending Events from the Dev Console

It's simple to send/receive messages from the Dev Console using Socket.IO
by following these instructions.
You must simply follow the format of the message and issue a Publish Message
using your `Channel Name` and `Namespace` used in your Socket.IO app.

# Sending Events from a Server or Dev Console

This example shows you how to send events to your Socket.IO clients
using other PubNub libraries.  We are using the simple syntax of `Python`
here for the example:

```python
from PubNub import PubNub

## Create a PubNub Object
pubnub = PubNub( 'demo', 'demo', None, False )

## Publish To Socket.IO
pubnub.publish({
    'channel' : 'my_pn_channel',
    'message' : {
        "name" : "message",                  ## Event Name
        "ns"   : "example-ns-my_pn_channel", ## Namespace
        "data" : { "my" : "data" }           ## Your Message
    }
})

