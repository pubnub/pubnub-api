/**
 * Author: WikiFlashed
 * Released under: MIT or whatever license allowed by PubNub.
 * Use of this file at your own risk. WikiFlashed holds no responsibility or liability to what you do with this.
 */
package PubNub
{
	//import com.adobe.serialization.json.JSON;
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.SHA256;
	import com.adobe.net.URI;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpListener;
	import org.httpclient.HttpClient;


	/**
	 * PubNub Static Class
	 * 
	 * This should allow creating threads of listeners to each individual channel
	 * 
	 * @author Fan
	 */
	public class PubNub extends EventDispatcher
	{
		private static var INSTANCE:PubNub;     
		private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
		
		public var initialized:Boolean = false;         
		public var origin:String = "http://pubsub.pubnub.com";          
		public var ssl:Boolean = false;
		public var interval:Number = 10;
		
		private var publish_key:String = "demo";
		private var sub_key:String = "demo";
		private var secret_key:String = "";
		private var cipher_key:String = "";
		
		private var subscriptions:Array;
		private var start_time_token:Number = 0;
		private var queue:Array;
        private var session_uuid:String = "";

		private var ori:Number = Math.floor(Math.random() * 9) + 1;

        private function nextOrigin(origin:String):String
		{
			return origin.indexOf('pubsub') > 0
				&& origin.replace(
					'pubsub', 'ps' + (++ori < 10 ? ori : ori=1)
				) || origin;
		}

        public function getSessionUUID():String {
            return this.session_uuid;
        }

		public function PubNub(enforcer:SingletonEnforcer) 
		{
			
		}
		
		public static function getInstance():PubNub
		{ 
			if (!INSTANCE) 
			{
				INSTANCE = new PubNub(new SingletonEnforcer());
				
			}
			return INSTANCE;
		}
		
		/**
		 * ??
		 * Hash Array
		 * origin = https:// or http://
		 * @param config
		 */
		public function init(config:Object):void
		{
			if(config.ssl && config.origin)
			{
				origin = "https://" + config.origin;
			}
			else if (config.origin)
			{
				origin = "http://" + config.origin;
			}
			
			if(config.publish_key)
			{
				publish_key = config.publish_key;
			}
			
			if(config.sub_key)
			{
				sub_key = config.sub_key;
			}
			
			if(config.secret_key)
			{
				secret_key = config.secret_key;
			}
			
			if(config.cipher_key)
			{
				this.cipher_key = config.cipher_key;
			}
			
			if (config.push_interval)
			{
				interval = config.push_interval;
			}
			
			queue = [];
            subscriptions = [];
            this.session_uuid = INSTANCE._uid();



            function dataHandler( evt:HttpDataEvent ):void {
					
			trace('dataHandler');
				var result:Object;
				try{
					result = JSON.parse(evt.readUTFBytes());        
					start_time_token = result[0];
                    start_time_token = 0;
					initialized = true;
				} catch (e:*) {
				 	// TODO: throw an exeption or an error event
					trace("[PubNub] Bad JSON Content");
				}
				
				dispatchEvent(new PubNubEvent(PubNubEvent.INIT));
			}
			var url:String = origin + "/" + "time" + "/" + 0;
			
			// Loads Time Token
			_request( { url:url, channel:"system", handler:dataHandler, uid:"init" } );
		}               
		
		/**
		 * Wrapper for function below
		 * @param       args
		 */
		public static function publish(args:Object):void
		{
			
			if (!INSTANCE.initialized)
			{
				throw("[PUBNUB] Not initialized yet");
			}                   
			INSTANCE._publish(args);
		}
		
		/**
		 * Broadcasts a message
		 * args: { callback:Function, channel:"String", message:"String|Array|Object" }
		 * ????
		 * @param args
		 */
		public function _publish(args:Object):void
		{
			var onResult:Function = args.callback || dispatchEvent;
			
			if (!args.channel || !args.message)
			{
				onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Channel Not Given and/or Message"], timeout:1000 } ));
				return;
			}
			var channel:String          = args.channel;
			var message:Object          = args.message;
			var signature:String        = "0";

            var serializedMessage:String = JSON.stringify(message);

            if (secret_key)
			{
				// Create the signature for this message                
				var concat:String = publish_key + "/" + sub_key + "/" + secret_key + "/" + channel + "/" + serializedMessage;
				
				// Sign message using HmacSHA256
				signature = HMAC.hash(secret_key, concat,SHA256);        
			}

			if(this.cipher_key.length > 0)
			{
				var pubnubcrypto:PubnubCrypto = new PubnubCrypto();
				serializedMessage = JSON.stringify(pubnubcrypto.encrypt(this.cipher_key, serializedMessage));
			}
			
			var uid:String = _uid();
			
			function publishHandler( evt:Event ):void
			{
				var node:Object = queue[uid];
				var loader:URLLoader = node.loader;
				if ( evt.type == Event.COMPLETE )
				{
					try
					{
						var result:Object = JSON.parse(loader.data);                           
						onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:result, timeout:1 } ));
					}
					catch (e:*)
					{
						trace("[PubNub] Bad Data Content Ignored");
					}
				}
				else
				{
					onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Connection Issue"], timeout:1000 } ));
				}
				node.loader.close();
				node.loader = null;
				node.handler = null;
			}            
			var url:String = origin + "/" + "publish" + "/" + publish_key + "/" + sub_key + "/" + signature + "/" + _encode(channel) + "/" + 0 + "/" +_encode(serializedMessage as String);
			_request( { url:url, channel:channel, handler:publishHandler, uid:uid } );
		}
		
		/**
		 * Subscription Wrapper
		 * @param       args
		 */
		public static function subscribe(args:Object):void
		{
			if (!INSTANCE.initialized)
			{
				throw("[PUBNUB] Not initialized yet");
			}
			INSTANCE._subscribe(args);
		}
		
		/**
		 * Subscribes to a channel
		 * args: { callback:Function, channel:"String" }
		 * @param       args
		 */
		public function _subscribe(args:Object):void{
			var onResult:Function = args.callback || dispatchEvent;
			if (!args.callback){
				throw("[PubNub] Missing Callback Function");
				return;
			}
			
			if (!args.channel)
			{
				onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Channel Not Given"], timeout:1000 } ));
				return;
			}
			
			var channel:String = args.channel;             
			var time:Number = 0;
			if (!subscriptions[channel])
			{
				subscriptions[channel] = {}
			}
			
			if (subscriptions[channel].connected)
			{
				onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, { channel:channel, result:[-1, "Already Connected"], timeout:1000 } ));
				return;
			}
			
			subscriptions[channel].connected = true;
			
			var url:String = origin + "/" + "subscribe" + "/" + sub_key + "/" + _encode(channel) + "/" + 0;
			
			var uid:String = _uid();
			
			function subHandler( evt:HttpDataEvent ):void {
				var rawStr:String = evt.readUTFBytes();
				//trace('subHandler', rawStr);
				var node:Object = queue[uid];
				
				var loader:* = node.loader;
					
				if (!subscriptions[channel].connected){
					// Stops the connection or any further listening loops
					disposeNode(node);
					delete node.loader;
					delete node.channel;
					delete node.uid;
					delete node.timetoken;
					delete node.request;
					delete queue[uid];
					return;
				}
				var timer:Timer;
				if ( evt.type == HttpDataEvent.DATA){
					
					try {
						var result:Object = JSON.parse(rawStr);  
						time = result[1];
						//trace('rawStr : ' + rawStr);
						
						// Valid Response From Server so far
                        if(result is Array) {                            
							if (time == 0){
								onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE_CONNECTED, { channel:channel }));
							}
							else{
								var messages:Array = result[0];    
								if(messages) {
									for (var i:int = 0; i < messages.length; i++) 
									{
										if(cipher_key.length > 0)
										{
                                            var pubnubcrypto:PubnubCrypto = new PubnubCrypto();

											onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, { 
												channel:channel, 
												result:[i+1,pubnubcrypto.decrypt(cipher_key,messages[i])], 
												envelope: result, 
												timeout:1 
											} ));
										}
										else
										{
											onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, {
												channel:channel, 
												result:[i+1,JSON.stringify(messages[i])], 
												envelope: result, 
												timeout:1 
											} )); 
										}	
									}
								}
							}
							time = result[1];
						} 
					}
					catch (e:Error)
					{                        
						trace("[PubNub] Bad Data Content Ignored");
					}
					
					node.tries = 0;
					timer = new Timer(interval, 100);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						_request({ url:url, channel:channel, handler:subHandler, uid:uid, timetoken:time, operation:"subscribe_with_timetoken" });
					});
					timer.start();
				}
				else{
					// Possibly Network Issue, then try again after 1 second.
					onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, { channel:channel, result:[ -1, "Connection Issue"], timeout:1000 } ));                               
					node.tries++;
					
					if (node.tries == 30){
						// After 30 tries, seeming the network is now dead after 30 seconds.
						// Dispatches error event
						_unsubscribe({ channel:channel, uid:uid });
						dispatchEvent(new PubNubEvent(PubNubEvent.ERROR, { channel:channel, message:"Channel Dropped" } ));
					}
					else
					{
						timer = new Timer(1000, 1);
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
							_request({ url:url, channel:channel, handler:subHandler, uid:uid, timetoken:time, operation:"subscribe_with_retry" });
						});
						timer.start();
					}
				}
			}

			_request( { url:url, channel:channel, handler:subHandler, uid:uid, timetoken:time, operation:"subscribe_get_timetoken" } );
		}
		
		public static function history(args:Object):void
		{
			
			if (!INSTANCE.initialized)
			{
				throw("[PUBNUB] Not initialized yet");
			}                   
			INSTANCE._history(args);
		}
		public function _history(args:Object):void
		{
			var onResult:Function = args.callback || dispatchEvent;
			
			if (!args.channel || !args.limit)
			{
				onResult(new PubNubEvent(PubNubEvent.HISTORY, { channel:channel, result:[-1,"Channel Not Given and/or Limit"], timeout:1000 } ));
				return;
			}
			var channel:String   = args.channel;
			var limit:String   = args.limit;
			var uid:String = _uid();
			var url:String = origin + "/" + "history" + "/" + sub_key + "/" + _encode(channel) + "/" + 0 + "/" +_encode(limit);             
			function HistoryHandler( evt:Event ):void
			{
				var node:Object = queue[uid];
				var loader:URLLoader = node.loader;
				if ( evt.type == Event.COMPLETE ) 
				{
					try 
					{
						var result:Object = JSON.parse(loader.data); 
						if(result) 
						{
							var pubnubcrypto:PubnubCrypto = new PubnubCrypto();                                    
							for (var i:int = 0; i < result.length; i++) 
							{
								if(cipher_key.length > 0)
								{
									onResult(new PubNubEvent(PubNubEvent.HISTORY, { channel:channel, result:[i+1,pubnubcrypto.decrypt(cipher_key,result[i])],timeout:1 } ));
								}
								else
								{
									onResult(new PubNubEvent(PubNubEvent.HISTORY, { channel:channel, result:[i+1,JSON.stringify(result[i])],timeout:1 } )); 
								}    
							}
						}
					}
					catch (e:*)
					{
						trace("[PubNub history] Bad Data Content Ignored");
					}
				}
				else
				{
					onResult(new PubNubEvent(PubNubEvent.HISTORY, { channel:channel, result:[-1,"Connection Issue"], timeout:1000 } ));
				}
				node.loader.close();
				node.loader = null;
				node.handler = null;
			}
			_request( { url:url, channel:channel, handler:HistoryHandler, uid:uid, operation:"history" } );
		}
		
		public function detailedHistory(args:Object):void
		{
			var onResult:Function = args.callback || dispatchEvent;
			
			if (!args.channel)
			{
				onResult(new PubNubEvent(PubNubEvent.DETAILED_HISTORY, { channel:channel, result:[-1,"Channel Not Given and/or count"], timeout:1000 } ));
				return;
			}
			var channel:String   = args.channel;
			var count:String   = args.count || "100";
			var uid:String = _uid();
			var url:String = origin + "/v2/history/sub-key/" + sub_key + "/channel/" + _encode(channel);             

            var params:String = "count=" + _encode(count);

            if (args.start || args.end || args.reverse) {
                params = extractOptionalParams(args, params);
            }

            function DetailedHistoryHandler( evt:Event ):void
			{
				var node:Object = queue[uid];
				//var loader:URLLoader = node.loader;
				var loader:* = node.loader;
				if ( evt.type == Event.COMPLETE ) 
				{
					try 
					{
						var result:Object = JSON.parse(loader.data);
						if(result) 
						{
							var pubnubcrypto:PubnubCrypto = new PubnubCrypto();                                    
							for (var i:int = 0; i < result[0].length; i++) 
							{
								if(cipher_key.length > 0)
								{
									onResult(new PubNubEvent(PubNubEvent.DETAILED_HISTORY, { channel:channel, result:[i+1,pubnubcrypto.decrypt(cipher_key,result[0][i])],timeout:1 } ));
								}
								else
								{
									onResult(new PubNubEvent(PubNubEvent.DETAILED_HISTORY, { channel:channel, result:[i+1,JSON.stringify(result[0][i])],timeout:1 } )); 
								}    
							}
						}
					}
					catch (e:*)
					{
                        trace("[PubNub detailed history] Bad Data Content Ignored");
                        onResult(new PubNubEvent(PubNubEvent.DETAILED_HISTORY, { channel:channel, result:[0, "Invalid JSON Received."] } ));
					}
				}
				else
				{
					onResult(new PubNubEvent(PubNubEvent.DETAILED_HISTORY, { channel:channel, result:[-1,"Connection Issue"], timeout:1000 } ));
				}
				node.loader.close();
				node.loader = null;
				node.handler = null;
			}
			_request( { url:url, params:params, channel:channel, handler:DetailedHistoryHandler, uid:uid, operation:"detailedHistory" } );
		}

        private function extractOptionalParams(args:Object, params:String):String {
            var optionalParams:Object = {};

            if (args.start != null) {
                optionalParams["start"] = args.start;
            }
            if (args.end != null) {
                optionalParams["end"] = args.end;
            }
            if (args.reverse != null) {
                if (args.reverse == true) {
                    optionalParams["reverse"] = true;
                } else if (args.reverse == false) {
                    optionalParams["reverse"] = false;
                }
            }

            for (var key:String in optionalParams) {
                params += "&" + key + "=" + optionalParams[key];
            }
            return params;
        }

        public static function time(args:Object):void
		{
			if (!INSTANCE.initialized)
			{
				throw("[PUBNUB] Not initialized yet");
			}
			INSTANCE._time(args);
		}


        public function here_now(args:Object):void
        {
            var uid:String = _uid();
            var onResult:Function = args.callback || dispatchEvent;

            if (!args.channel) {
                return;
            }

            var url:String = origin + "/" + "v2/presence/sub_key/" + this.sub_key + "/channel/" + args.channel;
            ExternalInterface.call( "console.log", ("here_now url is: " + url) );

            function HereNowHandler( evt:Event ):void
            {

//                var result:Object = JSON.parse(evt.target.data);
//                ExternalInterface.call( "console.log", (result) );

//                TODO: Why doesn't this work here?
//                var node:Object = queue[uid];
//                var loader:URLLoader = node.loader;
//                var result:Object = JSON.parse(evt.target);
//                ExternalInterface.call( "console.log", ("event receivied: " + result) );


                if ( evt.type == Event.COMPLETE )
                {
                    try
                    {
                        var result:Object = JSON.parse(evt.target.data);
                        if(result)
                        {
                            onResult(new PubNubEvent(PubNubEvent.HERE_NOW, {result:(result),timeout:1 } ));
                        }
                    }
                    catch (e:*)
                    {
                        trace("[PubNub here_now] Bad Data Content Ignored");
                    }
                }
                else
                {
                    onResult(new PubNubEvent(PubNubEvent.HERE_NOW, {result:["here_now Connection Issue"], timeout:1000 } ));
                }

//                node.loader.close();
//                node.loader = null;
//                node.handler = null;
            }

            ExternalInterface.call( "console.log", ("here now _request started.") );
            _request( { url:url, handler:HereNowHandler } );
        }

		public function _time(args:Object):void
		{
			trace('_time : ' + args);
			var onResult:Function = args.callback || dispatchEvent;
			var uid:String = _uid();
			var url:String = origin + "/" + "time" +  "/" + 0 ;    
			
			function TimeHandler( evt:Event ):void 
			{
				var node:Object = queue[uid];
				var loader:URLLoader = node.loader;
				if ( evt.type == Event.COMPLETE )
				{
					try
					{
						var result:Object = JSON.parse(loader.data);
						if(result)
						{
							onResult(new PubNubEvent(PubNubEvent.TIME, {result:[JSON.stringify(result[0])],timeout:1 } ));
						}
					}
					catch (e:*)
					{
						trace("[PubNub time] Bad Data Content Ignored");
					}
				}
				else
				{
					onResult(new PubNubEvent(PubNubEvent.TIME, {result:["Connection Issue"], timeout:1000 } ));
				}
				node.loader.close();
				node.loader = null;
				node.handler = null;
			}
			_request( { url:url, handler:TimeHandler, uid:uid } );
		}
		/**
		 * UnSubscription Wrapper
		 * @param       args
		 */
		public static function unsubscribe(args:Object):void
		{
			if (!INSTANCE.initialized)
			{
				throw("[PUBNUB] Not initialized yet");
			}                   
			INSTANCE._unsubscribe(args);
		}

		/**
		 * UnSubscribes to a channel
		 * args: { callback:Function, channel:"String" }
		 * @param       args
		 */
		public function _unsubscribe(args:Object):void{
			//trace('_unsubscribe : ' + args.channel);
			var onResult:Function = args.callback || dispatchEvent;   
			
			if (!args.channel){
				onResult(new PubNubEvent(PubNubEvent.UNSUBSCRIBE, { channel:channel, result:[-1,"Channel Not Given"], timeout:1000 } ));
				return;
			}
			var channel:String = args.channel;
			var nodes:Array = [];
			for each(var i:Object  in queue) {
				if (channel != null && (i.channel == channel)) {
                    disposeNode(i);
					delete queue[i.args];
					break;
				}

                i.loader.close();

            }
			
			 var node:Object = queue[args.uid];
			 trace('_unsubscribe : ' + args.uid, args.channel);

			if (subscriptions[channel] && subscriptions[channel].connected){
				subscriptions[channel].connected =  false;
			}

			var event:PubNubEvent = new PubNubEvent(PubNubEvent.UNSUBSCRIBE, { channel:channel, result:[1, "Channel '" + channel + "' Unsubscribed"], timeout:1000 } );
			onResult(event);
		}
		
		private function disposeNode(node:Object):void {
			//trace('----------disposeNode');
			if (!node) return;
			disposeNodeLoader(node);
			node.tries = null;
			node.uid = null;
			node.request = null;
			node.channel = null;
		}
		
		private function disposeNodeLoader(node:Object):void {
			var loader:HttpClient = node.loader as HttpClient;
			var listener:HttpListener = node.listener as HttpListener;
			if (loader) {
				try {
					loader.close();
					//trace('dispose  loader');
				}catch (err:Error) { }
			}
			
			if (listener) {
				listener.unregister();
				listener.onData = null;
				listener.onError = null;
			}
			
			node.loader = null;
			node.listener = null;
		}
		
		/**
		 * Helper Functions 
		 * ==============================================
		 */
		
		/**
		 * Makes a pub nub request
		 * @param       args
		 */


		//private var testArr:Array = [];
        public function _request(args:Object): void{
            var node:Object = { tries:0 }

            if (queue[args.uid] != null ) { node = queue[args.uid] };

            var loader:HttpClient = node.loader;
            var url:String = args.url;


            if (args.timetoken != null )
            {
                url += "/" + args.timetoken;

                    if ( args.operation == "subscribe_with_timetoken") {
                        url += "?uuid=" + this.session_uuid;
                    }
            }

			if (args.params != null) { 
				if (args.operation != "subscribe_with_timetoken")
					url = args.url + "?" + args.params;
				else
					url = args.url + "&" + args.params;
			}
			
			disposeNodeLoader(node);

			node.loader = loader = new HttpClient();
			var listener:HttpListener = new HttpListener();
			node.listener = listener;
			listener.onData = args.handler;
            listener.onClose = args.hander;

			// TODO: refactor to normal event listener
			//listener.onError = args.handler;
			   
			loader.get(new URI(url), listener);

            node.uid = args.uid;
            node.channel = args.channel;	
            queue[args.uid] = node;
        }
		
		/**
		 * Encodes a string into some format
		 * Should be the escape function
		 * @param       args
		 * @return
		 */
		public function _encode(args:String):String
		{
			return escape(args);
		}
		
		/**
		 * Apply function to all elements in a table
		 * @param       f
		 * @param       array
		 * @return
		 */
		public function _map(f:Function, array:Array):Array
		{
			return [];
		}
		
		
		public function _uid():String
		{
			var uid:Array = new Array(36);
			var index:int = 0;
			
			var i:int;
			var j:int;
			
			for (i = 0; i < 8; i++)
			{
				uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			
			for (i = 0; i < 3; i++)
			{
				uid[index++] = 45; // charCode for "-"
				
				for (j = 0; j < 4; j++)
				{
					uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
				}
			}
			
			uid[index++] = 45; // charCode for "-"
			
			for (i = 0; i < 8; i++)
			{
				uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			
			for (j = 0; j < 4; j++)
			{
				uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			
			var time:Number = new Date().getTime();
			// Note: time is the number of milliseconds since 1970,
			// which is currently more than one trillion.
			// We use the low 8 hex digits of this number in the UID.
			// Just in case the system clock has been reset to
			// Jan 1-4, 1970 (in which case this number could have only
			// 1-7 hex digits), we pad on the left with 7 zeros
			// before taking the low digits.
			
			return String.fromCharCode.apply(null, uid);
		}
	}
}

internal class SingletonEnforcer{}
