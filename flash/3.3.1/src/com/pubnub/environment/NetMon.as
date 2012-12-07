package com.pubnub.environment {
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class NetMon extends EventDispatcher {
		
		public var forceReconnect:Boolean = true;
		
		private var interval:int;
		private var _destroyed:Boolean;
		private var loader:URLLoader;
		private var lastStatus:String
		private var _origin:String;
		private var url:String;
		private var _isRunning:Boolean;
		private var sysMon:SysMon;
		private var _currentRetries:uint
		private var _maxForceReconnectRetries:uint = 100;
		private var _forceReconnectDelay:uint = 1000;
		private var _reconnectDelay:uint = 15000;
		
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
			reconnect();
		}
		
		private function onError(e:Event):void {
			// no network
			//trace('onError : ' + lastStatus);
			if (lastStatus == NetMonEvent.HTTP_DISABLE) {
				_currentRetries++;
				if (_currentRetries >= _maxForceReconnectRetries) {
					stop();
					lastStatus = NetMonEvent.MAX_RETRIES;
					dispatchEvent(new NetMonEvent(NetMonEvent.MAX_RETRIES));
				}
				return;
			}
			lastStatus = NetMonEvent.HTTP_DISABLE;
			if (forceReconnect) {
				clearInterval(interval);
				interval = setInterval(ping, _forceReconnectDelay);
			}
			dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE));
		}
		
		private function onComplete(e:Event):void {
			// network ready
			//trace('onComplete : ' + lastStatus);
			if (lastStatus == NetMonEvent.HTTP_ENABLE) return;
			lastStatus = NetMonEvent.HTTP_ENABLE;
			if (forceReconnect) {
				clearInterval(interval);
				interval = setInterval(ping, _reconnectDelay);
			}
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
			_currentRetries = 0;
			lastStatus = null;
			reconnect();
			sysMon.start();
			_isRunning = true;
		}
		
		private function reconnect():void {
			stop();
			ping();
			interval = setInterval(ping, _reconnectDelay);
		}
		
		public function stop():void {
			_isRunning = false;
			lastStatus = null;
			sysMon.stop();
			clearInterval(interval);
		}
		
		public function destroy():void {
			if (_destroyed) return;
			stop();
			sysMon.stop();
			sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			sysMon = null;
			
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			try {
				loader.close();
			}catch (err:Error) { }
			loader = null;
			_destroyed = true;
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
		
		public function get currentRetries():uint {
			return _currentRetries;
		}
		
		public function get maxForceReconnectRetries():uint {
			return _maxForceReconnectRetries;
		}
		
		public function set maxForceReconnectRetries(value:uint):void {
			_maxForceReconnectRetries = value;
		}
		
		public function get forceReconnectDelay():uint {
			return _forceReconnectDelay;
		}
		
		public function set forceReconnectDelay(value:uint):void {
			_forceReconnectDelay = value;
		}
		
		public function get reconnectDelay():uint {
			return _reconnectDelay;
		}
		
		public function set reconnectDelay(value:uint):void {
			_reconnectDelay = value;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}