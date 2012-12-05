package com.pubnub.operation {
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.loader.*;
	import com.pubnub.net.*;
	import flash.events.*;
	import flash.net.URLRequestMethod;
	import org.casalib.events.RemovableEventDispatcher;
	import org.httpclient.events.*;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	[Event(name="OperationEvent.fault", type="com.pubnub.operation.OperationEvent")]
	[Event(name="OperationEvent.result", type="com.pubnub.operation.OperationEvent")]
	public class Operation extends RemovableEventDispatcher {
		
		static public const WITH_TIMETOKEN:String = 'subscribe_with_timetoken';
		static public const GET_TIMETOKEN:String = 'subscribe_get_timetoken';
		//static public const PNPRES_GET_TIMETOKEN:String = 'pnpres_subscribe_get_timetoken';
		static public const WITH_RETRY:String = 'subscribe_with_retry';
		static public const LEAVE:String = 'leave';
		
		public var keepAlive:Boolean = true;
		public var origin:String;
		public var uid:String;
		public var channel:String;
		public var sessionUUID:String;
		public var parseToJSON:Boolean = true;
		public var timetoken:*;
		public var operation:String;
		public var subscribeKey:String = ""; 
		protected var _request:URLRequest;
		
		protected var _url:String;
		protected var _destroyed:Boolean;
		
		public function Operation() {
			super(null);
			init();
		}
		
		protected function init():void {
			// abstract
		}
		
		public function createURL(args:Object = null):void {
			//trace(this, 'send');
			var url:String = args.url;
			uid = args.uid;
			sessionUUID = args.sessionUUID;
			channel = args.channel;
			timetoken = args.timetoken;
			operation = args.operation;
			//trace(operation, timetoken);
            if (timetoken != null ){
                url += "/" + timetoken;
				if (operation == WITH_TIMETOKEN || 
					operation == GET_TIMETOKEN) {
					url += "?uuid=" + sessionUUID;
				}
            }

			if (args.params != null) { 
				if (args.operation != WITH_TIMETOKEN )
					url = args.url + "?" + args.params;
				else
					url = args.url + "&" + args.params;
			}
			
			
			_url = url;
			createRequest();
		}
		
		protected function createRequest():void {
			_request = new URLRequest(url);
			_request.method = URLRequestMethod.GET;
			//_request.header = new URLRequestHeader([ { name: "Connection", value: "Keep-Alive" } ]);
			_request.header = new URLRequestHeader();
		}
		
		override public function destroy():void {
			super.destroy();
			if (_destroyed) return;
			_destroyed = true;
			_request.destroy();
			_request = null;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function get request():URLRequest {
			return _request;
		}
		
		
		
		public function onData(data:Object = null):void {
			//trace(this, data);
			var result:Object = data;
			if (parseToJSON) {
				try {
					result = PnJSON.parse(String(data));
				}catch (err:Error) {
					//trace('dasdasdasdasd');
					dispatchEvent(new OperationEvent(OperationEvent.FAULT, { message:'Error JSON parse', id:'-1' } ));
					return;
				}
			}
			dispatchEvent(new OperationEvent(OperationEvent.RESULT, result));
		}
		
		public function onError(data:Object = null):void {
			
		}
		
	}
}