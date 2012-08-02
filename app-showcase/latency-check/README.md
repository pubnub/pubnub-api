# PubNub Latency Check Example

A quick example with PubNub, and using the Ping API to detect the
latency and connectivity of the device.
This type of test provides insight into deliverability performance
expectations which can be directly relayed to the user allowing
you (the app developer) to set the expectations of the experience
based on the user's current connection speed.

## Get Started

Check out this code.
It shows you how to get started with detecting device latency. 
It simply sends a ping to PubNub and tracks round-trip send/receive
status.
Note that a slow response is typically related to the connection speed
of the device and also relates to network traffic capabilities
in the local area.

```javascript
function connection_latency(callback) {
    connection_latency.start = now();

    PUBNUB.time(function(){
        callback(now() - connection_latency.start);
        setTimeout( function(){ connection_latency(callback) }, 1000 );
        clearInterval(connection_latency.ival);
        connection_latency.ival = 0;
    });

    if (connection_latency.ival) return;

    connection_latency.ival = setInterval( function() {
        callback(now() - connection_latency.start);
    }, 1500 );

    return connection_latency.ival;
}
function now(){return+new Date}
```

> This code shows delivery round-trip speed testing
using PubNub's high available Global Distribution Network.

## How to Use it?

Simple use this method by following the example:

```javascript
connection_latency(function(latency){
    // Show currnet Latency
    console.log(latency);
});
```

> This code is executed periodically for a continuous latency test.

That's it!
See the full example in the `latency.html` file in this directory.
