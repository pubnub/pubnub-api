'experiment for getting pubnub working in monkey!

Private

'imports based on target
#if TARGET="html5"
	'html5
	Import "native/html5/glue.js"
#ElseIf TARGET="flash"
	'flash
	'damn this is a fugly way to do ....
	Import "native/flash/com/adobe/serialization/json/JSON.as"
	Import "native/flash/com/adobe/serialization/json/JSONEncoder.as"
	Import "native/flash/com/adobe/serialization/json/JSONDecoder.as"
	Import "native/flash/com/adobe/serialization/json/JSONToken.as"
	Import "native/flash/com/adobe/serialization/json/JSONTokenType.as"
	Import "native/flash/com/adobe/serialization/json/JSONTokenizer.as"
	Import "native/flash/com/adobe/serialization/json/JSONParseError.as"
	import "native/flash/com/adobe/utils/IntUtil.as"
	import "native/flash/com/adobe/crypto/MD5.as"
	import "native/flash/com/adobe/webapis/ServiceBase.as"
	import "native/flash/com/adobe/net/DynamicURLLoader.as"
	import "native/flash/com/adobe/webapis/URLLoaderBase.as"
	Import "native/flash/PubNub.as"
	Import "native/flash/PubNubEvent.as"
	Import "native/flash/glue.as"
#Else
#End

Public

Extern

Function PubNubStart(publishKey:String,subscribeKey:String,secretKey:String="") = "pubNubStart"
Function PubNubLoaded:Int() = "pubNubLoaded"
Function PubNubSubscribe:PubNubChannel(id:String) = "pubNubSubcribe"

Class PubNubChannel = "pubNubChannel"
	Method Send(value:String) = "send"
	Method Connected:Int() = "connected"
	Method MessageAvailable:Int() = "messageAvailable"
	Method NextMessage:String() = "nextMessage"
	Method Fetch(amount:Int) = "fetch"
	Method Fetching:Int() = "fetching"
	Method FetchAvailable:Int() = "fetchAvailable"
	Method NextFetch:String() = "nextFetch"
	Method Id:String() = "id"
End
	
Public
