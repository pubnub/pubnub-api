//globals
var _pubNubInitSuccess:Boolean = false;

//functions
function pubNubStart(publishKey:String,subscribeKey:String,secretKey:String):void {
	// --- start the pubnub runtime ---
	var pub:PubNub = PubNub.getInstance();

	var config:Object = {
		push_interval:10,
		publish_key:publishKey,
		sub_key:subscribeKey,
		secret_key:secretKey			
	}

	pub.addEventListener(PubNubEvent.INIT, _pubNubStartCallback);
	pub.init(config);
}

function _pubNubStartCallback():void {
	// --- callback after init ---
	_pubNubInitSuccess = true;
}

function pubNubLoaded():Boolean {
	// --- returns true if pubnub is loaded ---
	return _pubNubInitSuccess;
}

function pubNubSubcribe(id:String):pubNubChannel {
	// --- subscribe to a channel and return the channel object ---
	return new pubNubChannel(id);
}


//classes
class pubNubChannel {
	internal var channel:String;
	internal var isConnected:Boolean = false;
	internal var isFetching:int = 0;
	internal var messages:Array = new Array(0);
	internal var history:Array = new Array(0);
	
	function pubNubChannel(id:String) {
		// --- setup the channel ---
		this.channel = id;
		
		//subscribe
		PubNub.subscribe({callback:this.onSubscribeHandler, channel:this.channel});
		this.isConnected = true;//????
	}
	
	private function onSubscribeHandler(evt:PubNubEvent):void {
		// --- subscription handler ---
		if (evt.data.result[0]) { this.messages.push(String(evt.data.result[1])); }
	}
	
	private function onPublishHandler(evt:PubNubEvent):void {
		//showError("published");
		//trace("[TestSender] onPublishHandler code: " + evt.data.result[0] + " | " + evt.data.result[1]);
		//t.htmlText = "[TestSender] onPublishHandler code: " + evt.data.result[0] + " | " + evt.data.result[1] + "<br/>"+t.htmlText;
	}
	
	private function onHistoryHandler(evt:PubNubEvent):void {
		//success
		this.isFetching--;

		//convert to strings and add to history
		for(var index:int=0;index<evt.data.result[1].length;index++) {
			this.history.push(String(evt.data.result[1][index]));
		}
	}
	
	public function send(value:String):void {
		// --- send a message ---
		PubNub.publish({callback:this.onPublishHandler,channel:this.channel, message:value});
	}
	
	public function connected():Boolean {
		// --- return true if connected ---
		return isConnected;
	}
	
	public function fetch(amount:int):void {
		// --- fetch items from the history ---
		this.isFetching++;
		this.history = [];
		PubNub.history({callback:this.onHistoryHandler,channel:this.channel,limit:amount});
	}
	
	public function fetching():Boolean {
		// --- returns true if currently fetching history ---
		return (this.isFetching > 0);
	}
	
	public function fetchAvailable():int {
		// --- returns the number of history waiting ---
		return this.history.length;
	}
	
	public function nextFetch():String {
		// --- returns a history if there is one ---
		if (this.history.length > 0) { return this.history.shift(); }
		return "";
	}
	
	public function messageAvailable():int {
		// --- returns the number of messages waiting ---
		return this.messages.length; 
	}
	
	public function nextMessage():String {
		// --- returns a message if there is one ---
		if (this.messages.length > 0) { return this.messages.shift(); }
		return "";
	}
	
	public function id():String {
		// --- returns name of channel ---
		return this.channel;
	}
}