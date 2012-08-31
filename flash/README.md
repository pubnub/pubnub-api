# YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

## PubNub 3.3 Real-time Cloud Push API - AS3

PubNub is a blazingly fast cloud-hosted messaging service for building
real-time web and mobile apps. Hundreds of apps and thousands of developers
rely on PubNub for delivering human-perceptive real-time
experiences that scale to millions of users worldwide. PubNub delivers
the infrastructure needed to build amazing MMO games, social apps,
business collaborative solutions, and more.

## Examples
Checkout 3.3/MessageBox.as for an AS3/Flex 4.6-based example. Other examples may be CS 5.0-based.

## TUTORIAL: HOW TO USE

### Flash AS3 : (Init)

```javascript
//set the channel
var channelName:String = "hello-world";

// Initialize pubnub state
var pubnub:PubNub = PubNub.getInstance(); 
var config:Object = {    
    push_interval:10,
    publish_key:"demo",
    sub_key:"demo",
    secret_key:"demo",
    cipher_key:"demo"
}    
pubnub.init(config);    
```

### Flash AS3 : (Publish)

```javascript
//Publish the messages of type String, json array, and json object
pubnub.addEventListener(PubNubEvent.INIT, onPubInit);
function onPubInit(event:PubNubEvent):void
{
    var msgArr:Array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    var msgObj:Object = {"Name":"Jhon","Age":"25"};
    
    PubNub.publish( { callback:onPublishHandler, channel:channelName, message:"Hello AS3"} ); //string message
    PubNub.publish( { callback:onPublishHandler, channel:channelName, message:msgArr} ); // array
    PubNub.publish( { callback:onPublishHandler, channel:channelName, message:msgObj} ); //object
}
function onPublishHandler(evt:PubNubEvent):void
{
    trace("[" + evt.data.result[0] + " ," + evt.data.result[1]+ " ," + evt.data.result[2] + "]");
}
```

### Flash AS3 : (Subscribe)

```javascript
//Subscribe messages of type string,json array and json object
pubnub.addEventListener(PubNubEvent.INIT, onSubInit);
function onSubInit(event:PubNubEvent):void
{
    PubNub.subscribe( {
        callback:onSubscribeHandler,
        channel:channelName
    } );
}
function onSubscribeHandler(evt:PubNubEvent):void
{  
    trace("[Subscribed data] : " + evt.data.result[1]);
    trace("[Envelop data] : ", evt.data.envelope);
    trace("[Source Channel] : ", evt.data.envelope[2]);
}
```

### Flash AS3 : (Presence)

```javascript
function onPresenceHandler(evt:PubNubEvent):void {
    ExternalInterface.call( "console.log", ("presence event received.") );
    ExternalInterface.call( "console.log", ("Entering onPresenceHandler()") );
    ExternalInterface.call( "console.log", (this) );
    ExternalInterface.call( "console.log", (evt.data.result) );
}

PubNub.PubNub.subscribe({
    callback:onPresenceHandler,
    channel:channelName + "-pnpres"
});

```

### Flash AS3 : (History, deprecated, use detailedHistory below instead.)

```javascript
//Message history (deprecated by detailedHistory)
pubnub.addEventListener(PubNubEvent.INIT, onHistInit);
function onHistInit(event:PubNubEvent):void
{
    PubNub.history({ callback:onHistoryHandler, channel:channelName, limit:"3"});
}
function onHistoryHandler(evt:PubNubEvent):void
{  
    trace("[History data] : " + evt.data.result[1]);
}
```

### Flash AS3 : (detailedHistory)


```javascript
//Granular, detailed message history with offsets
pubnub.addEventListener(PubNubEvent.INIT, onHistInit);
function onHistInit(event:PubNubEvent):void
{
    PubNub.detailedHistory({ callback:onHistoryHandler, channel:channelName, limit:3, start:999, end:1004, reverse:false});
}
function onHistoryHandler(evt:PubNubEvent):void
{  
    trace("[History data] : " + evt.data.result[1]);
}

Required Parameters:

    'channel' - The channel name
    
Optional Parameters:
	
    'start' - Start timetoken
	'end' - End timetoken
    'limit' - Max number of returned results. Defaults and max is 100.
	'reverse' - Default is false, which is oldest first. Use true to return newest first, but only when start or end is omitted.

```


### Flash AS3 : (Time)

```javascript
//Get the time
pubnub.addEventListener(PubNubEvent.INIT, onTimeInit);
function onTimeInit(event:PubNubEvent):void
{
    PubNub.time({ callback:onTimeHandler});
}
function onTimeHandler(evt:PubNubEvent):void
{  
    trace("[Time] : " + evt.data.result[0]);
}
```
    
### Flash AS3 : (UUID)

```javascript
// Get UUID
var uid:String = pubnub._uid();        
trace("Generated UUID is :" + uid);
```

### Flash AS3 : (here_now)

```javascript
function onHereNowHandler(evt:PubNubEvent):void {
    ExternalInterface.call( "console.log", ("here_now() event received.") );
    ExternalInterface.call( "console.log", ("Entering onHerNowHandler()") );
    ExternalInterface.call( "console.log", (evt.data.result) );
}


pubnub.here_now({
    callback:onHereNowHandler,
    channel:channelName
});
```