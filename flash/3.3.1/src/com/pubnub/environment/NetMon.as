package com.pubnub.environment {
	import com.pubnub.*;
	import com.pubnub.connection.*;
	import com.pubnub.log.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	[Event(name="enable", type="com.pubnub.environment.NetMonEvent")]
	[Event(name="disable", type="com.pubnub.environment.NetMonEvent")]
	[Event(name="max_retries", type="com.pubnub.environment.NetMonEvent")]
	public class NetMon extends EventDispatcher {
		
		public var forceReconnect:Boolean = true;
		
		private var pingDelayTimeout:int;
		private var pingTimeout:int;
		private var pingStartTime:int;
		private var _destroyed:Boolean;
		
		private var lastStatus:String
		private var _isRunning:Boolean;
		private var sysMon:SysMon;
		private var _currentRetries:uint
		private var _maxRetries:uint = 100;
		private var loader:URLLoader;
		
		public function NetMon () {
			super(null);
			init();
		}
		
		private function init():void {
			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, 	onLoaderHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, 			onLoaderError);
			
			sysMon = new SysMon();
			sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			
			lastStatus = NetMonEvent.HTTP_DISABLE;
		}
		
		private function onLoaderError(e:IOErrorEvent):void {
			//trace('onLoaderError');
		}
		
		private function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
			if (_isRunning == false) return;
			//trace('onLoaderHTTPStatus : '  + e.status);
			var pingEndTime:int = getTimer() - pingStartTime;
			clearTimeout(pingDelayTimeout);
			clearTimeout(pingTimeout);
			if (e.status == 0) {
				onError(null);
			}else {
				onComplete(null);
			}
			
			if (pingEndTime >= Settings.PING_OPERATION_INTERVAL) {
				ping();
			}else {
				//trace('### : ' + (Settings.PING_OPERATION_INTERVAL - pingEndTime));
				pingDelayTimeout = setTimeout(ping,  Settings.PING_OPERATION_INTERVAL - pingEndTime);
			}
		}
		
		private function ping():void {
			if (_isRunning == false) return;
			clearTimeout(pingTimeout);
			pingStartTime = getTimer();
			pingTimeout = setTimeout(onTimeout, Settings.PING_OPEARTION_TIMEOUT);
			closeLoader();
			loader.load(new URLRequest(Settings.PING_OPERATION_URL));
		}
		
		private function onRestoreFromSleep(e:SysMonEvent):void {
			//trace('onRestoreFromSleep');
			lastStatus = null;
			reconnect();
		}
		
		private function onTimeout():void {
			//trace('onTimeout');
			onError(null);
			ping();
		}
		
		private function onError(e:Event = null):void {
			//Log.logRetry('PING : ERROR', Log.NORMAL);
			if (lastStatus == NetMonEvent.HTTP_ENABLE) {
				Log.logRetry('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network unavailable', Log.WARNING);
				dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE));
			}
			
			lastStatus = NetMonEvent.HTTP_DISABLE;
			_currentRetries++;
			if (_currentRetries >= _maxRetries) {
				stop();
				Log.logRetry('RETRY_LOGGING:RECONNECT_HEARTBEAT: maximum retries  of ['  + _maxRetries + '] reached', Log.WARNING);
				dispatchEvent(new NetMonEvent(NetMonEvent.MAX_RETRIES));
			}else {
				Log.logRetry('RETRY_LOGGING:RECONNECT_HEARTBEAT: Retrying [' +  _currentRetries + '] of maximum [' + _maxRetries + '] attempts', Log.WARNING);
			}
		}
		
		private function onComplete(e:Event = null):void {
			_currentRetries = 0;
			if (lastStatus != NetMonEvent.HTTP_ENABLE) {
				Log.logRetry('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network available', Log.NORMAL);
				dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_ENABLE));
			}
			lastStatus = NetMonEvent.HTTP_ENABLE;
		}
		
		public function start():void {
			//trace(this, 'start : ' + _isRunning);
			if (_isRunning) return;
			_currentRetries = 0;
			lastStatus = null;
			reconnect();
			sysMon.start();
			
		}
		
		private function reconnect():void {
			stop();
			_isRunning = true;
			ping();
		}
		
		public function stop():void {
			_isRunning = false;
			lastStatus = null;
			sysMon.stop();
			clearTimeout(pingDelayTimeout);
			clearTimeout(pingTimeout);
		}
		
		public function destroy():void {
			if (_destroyed) return;
			stop();
			sysMon.stop();
			sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			sysMon = null;
			
			closeLoader();
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, 	onLoaderHTTPStatus);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, 			onLoaderError);
			loader = null;
			_destroyed = true;
		}
		
		private function closeLoader():void {
			try {
				loader.close();
			}catch (err:Error) { };
		}
		
		public function get isRunning():Boolean {
			return _isRunning;
		}
		
		public function get currentRetries():uint {
			return _currentRetries;
		}
		
		public function get maxRetries():uint {
			return _maxRetries;
		}
		
		public function set maxRetries(value:uint):void {
			_maxRetries = value;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}