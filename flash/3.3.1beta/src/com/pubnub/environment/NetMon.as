package com.pubnub.environment {
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class NetMon extends EventDispatcher {
		
		// timeout for "time function"
		static public const HEARTBEAT:int = 15000;
		static public const FORCE_RECONNECT_TIMEOUT:int = 1000;
		
		public var forceReconnect:Boolean = true;
		
		private var interval:int;
		private var loader:URLLoader;
		private var lastStatus:String
		private var _origin:String;
		private var url:String;
		private var _isRunning:Boolean;
		private var sysMon:SysMon;
		
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
			
			sysMon = new SysMon();
			sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
		}
		
		private function onRestoreFromSleep(e:SysMonEvent):void {
			//trace('onRestoreFromSleep');
			lastStatus = null;
			heartbeat();
		}
		
		private function onError(e:Event):void {
			// no network
			//trace('onError : ' + lastStatus);
			if (lastStatus == NetMonEvent.HTTP_DISABLE) return;
			lastStatus = NetMonEvent.HTTP_DISABLE;
			if (forceReconnect) {
				clearInterval(interval);
				interval = setInterval(ping, FORCE_RECONNECT_TIMEOUT);
			}
			dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE));
		}
		
		private function onComplete(e:Event):void {
			// network ready
			//trace('onComplete : ' + lastStatus);
			if (lastStatus == NetMonEvent.HTTP_ENABLE) return;
			lastStatus = NetMonEvent.HTTP_ENABLE;
			if (forceReconnect) {
				//trace('to HEARTBEAT');
				clearInterval(interval);
				interval = setInterval(ping, HEARTBEAT);
			}
			//setTimeout(dispatchEvent, 200, new NetMonEvent(NetMonEvent.HTTP_ENABLE));
			dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_ENABLE));
		}
		
		private function ping():void {
			//trace('ping');
			try { loader.close(); }
			catch (err:Error) { };
			loader.load(new URLRequest(url));
		}
		
		public function start():void {
			if (_isRunning) return;
			heartbeat();
			sysMon.start();
			_isRunning = true;
		}
		
		private function heartbeat():void {
			stop();
			ping();
			interval = setInterval(ping, HEARTBEAT);
		}
		
		public function stop():void {
			_isRunning = false;
			sysMon.stop();
			clearInterval(interval);
		}
		
		public function destroy():void {
			stop();
			sysMon.stop();
			sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			sysMon = null;
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