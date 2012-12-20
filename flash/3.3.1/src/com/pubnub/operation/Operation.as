package com.pubnub.operation {
	import com.pubnub.json.PnJSON;
	import com.pubnub.net.URLRequest;
	import com.pubnub.net.URLRequestHeader;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequestMethod;
	import org.casalib.events.RemovableEventDispatcher;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Operation extends RemovableEventDispatcher {
		private var args:Object;
		
		static public const HTTPS_PATTERN:RegExp = new RegExp("(https):\/\/");
		
		public var parseToJSON:Boolean = true;
		
		protected var _origin:String;
		protected var _url:String;
		protected var _destroyed:Boolean;
		protected var _completed:Boolean;
		protected var _request:URLRequest;
		
		public function Operation(origin:String) {
			super();
			_origin = origin;
			init();
		}
		
		protected function init():void {
			// absrtract
		}
		
		public function setURL(url:String = null, args:Object = null):URLRequest {
			this.args = args;
			_url = url;
			return createRequest();
		}
		
		protected function createRequest():URLRequest {
			_completed = false;
			_request = new URLRequest(url);
			_request.method = URLRequestMethod.GET;
			_request.header = new URLRequestHeader();
			return request;
		}
		
		public function onData(data:Object = null):void {
			var result:Object = data;
			_completed = true;
			var error:Boolean;
			if (parseToJSON) {
				try {
					result = PnJSON.parse(String(data));
				}catch (err:Error) {
					error = true;
				}
			}
			
			if (error) {
				dispatchEvent(new OperationEvent(OperationEvent.FAULT, { message:'Error JSON parse', id:'-1' } ));
			}else {
				dispatchEvent(new OperationEvent(OperationEvent.RESULT, result));
			}
			destroy();
		}
		
		public function onError(data:Object = null):void {
			_completed = true;
			dispatchEvent(new OperationEvent(OperationEvent.FAULT, { message:(data ? data.message : data) } ));
			destroy();
		}
		override public function destroy():void {
			if (destroyed) return;
			super.destroy();
			args = null;
			_request.destroy();
			_request = null;
			
		}
		public function get origin():String {
			return _origin;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function get completed():Boolean {
			return _completed;
		}
		
		public function get request():URLRequest {
			return _request;
		}
		
		public function get ssl():Boolean { 
			return HTTPS_PATTERN.test(_url); 
		}
	}
}