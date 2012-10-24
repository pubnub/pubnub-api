package com.pubnub.environment {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class NetMon extends EventDispatcher {
		
		// timeout for "time function"
		static public const HEARTBEAT:int = 5000;
		private var interval:int;
		private var loader:URLLoader;
		private var lastStatus:String
		private var _origin:String;
		private var url:String;
		private var _isRunning:Boolean
		
		public function NetMon (origin:String = null) {
			super(null);
			this.origin = origin;
			init();
		}
		
		private function init():void {
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}
		
		private function onError(e:Event):void {
			// no network
			//trace('onError');
			if (lastStatus == NetMonEvent.HTTP_DISABLE) return;
			lastStatus = NetMonEvent.HTTP_DISABLE;
			dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE));
		}
		
		private function onComplete(e:Event):void {
			//trace('onComplete : ' + e.target.data);
			// network ready
			if (lastStatus == NetMonEvent.HTTP_ENABLE) return;
			lastStatus = NetMonEvent.HTTP_ENABLE;
			dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_ENABLE));
		}
		
		private function ping():void {
			try { loader.close(); }
			catch (err:Error) { };
			loader.load(new URLRequest(url));
		}
		
		public function start():void {
			if (_isRunning) return;
			_isRunning = true;
			stop();
			ping();
			interval = setInterval(ping, HEARTBEAT);
		}
		
		public function stop():void {
			_isRunning = false;
			clearInterval(interval);
		}
		
		public function destroy():void {
			stop();
		}
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
			url =  origin + "/" + "time" +  "/" + 0 ;
		}
		
		public function get isRunning():Boolean {
			return _isRunning;
		}
		
	}
}