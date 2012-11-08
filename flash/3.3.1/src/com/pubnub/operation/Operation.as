package com.pubnub.operation {
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.loader.*;
	import flash.events.*;
	import org.httpclient.events.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[Event(name="OperationEvent.fault", type="com.pubnub.operation.OperationEvent")]
	[Event(name="OperationEvent.result", type="com.pubnub.operation.OperationEvent")]
	public class Operation extends EventDispatcher {
		
		static public const WITH_TIMETOKEN:String = 'subscribe_with_timetoken';
		static public const GET_TIMETOKEN:String = 'subscribe_get_timetoken';
		static public const WITH_RETRY:String = 'subscribe_with_retry';
		
		public var uid:String;
		public var channel:String;
		public var sessionUUID:String;
		public var parseToJSON:Boolean = true;
		public var timetoken:*;
		public var operation:String;
		
		
		protected var _url:String;
		protected var _loader:PnURLLoader;
		protected var _destroyed:Boolean;
		
		public function Operation() {
			super(null);
			init();
		}
		
		protected function init():void {
			_loader = new PnURLLoader(Settings.OPERATION_TIMEOUT);
			_loader.addEventListener(PnURLLoaderEvent.COMPLETE, onLoaderData);
			_loader.addEventListener(PnURLLoaderEvent.ERROR, onLoaderError);
		}
		
		protected function onLoaderError(e:PnURLLoaderEvent):void {
			dispatchEvent(new OperationEvent(OperationEvent.FAULT,e.data ));
		}
		
		protected function onLoaderData(e:PnURLLoaderEvent):void {
			var result:* = e.data;
			if (parseToJSON) {
				try {
					result = PnJSON.parse(result);
				}catch (err:Error){
					dispatchEvent(new OperationEvent(OperationEvent.FAULT, { message:'Error JSON parse', id:'-1' } ));
					return;
				}
			}
			dispatchEvent(new OperationEvent(OperationEvent.RESULT, result));
		}
		
		public function send(args:Object):void {
			var url:String = args.url;
			uid = args.uid;
			sessionUUID = args.sessionUUID;
			channel = args.channel;
			timetoken = args.timetoken;
			operation = args.operation;
			//trace(operation, timetoken);
            if (timetoken != null ){
                url += "/" + timetoken;
				if (operation == WITH_TIMETOKEN || operation == GET_TIMETOKEN) {
					url += "?uuid=" + sessionUUID;
				}
            }

			if (args.params != null) { 
				if (args.operation != WITH_TIMETOKEN )
					url = args.url + "?" + args.params;
				else
					url = args.url + "&" + args.params;
			}
			this._url = url;
			//trace(operation, url);
			_loader.load(this._url);
		}
		
		public function close():void {
			try {
				_loader.close();
			}catch (err:Error) {}
		}
		
		public function destroy():void {
			if (_destroyed) return;
			_destroyed = true;
			_loader.removeEventListener(HttpDataEvent.DATA, onLoaderData);
			_loader.removeEventListener(HttpErrorEvent.ERROR, onLoaderError);
			_loader.removeEventListener(HttpErrorEvent.TIMEOUT_ERROR, onLoaderError);
			_loader.destroy();
			_loader = null;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
		
		public function get loader():PnURLLoader {
			return _loader;
		}
		
		public function get url():String {
			return _url;
		}
	}
}