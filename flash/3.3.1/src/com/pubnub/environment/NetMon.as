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
		
		private var interval:int;
		private var pingTimout:int;
		private var _destroyed:Boolean;
		private var loader:URLLoader;
		private var lastStatus:String
		private var _origin:String;
		private var url:String;
		private var _isRunning:Boolean;
		private var sysMon:SysMon;
		private var _currentRetries:uint
		private var _maxRetries:uint = 100;
		private var _reconnectDelay:uint = 15000;
		private var connection:HeartBeatConnection;
		private var timeOperation:TimeOperation;
		private var lastTime:int = 0
		
		public function NetMon (origin:String = null) {
			super(null);
			this.origin = origin;
			init();
		}
		
		private function init():void {
			/*loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, 					onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, 				onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 	onError);*/
			
			sysMon = new SysMon();
			sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			
			lastStatus = NetMonEvent.HTTP_DISABLE;
			
			connection = new HeartBeatConnection();
			connection.addEventListener(Event.CLOSE, onCloseConection);
		}
		
		private function onCloseConection(e:Event):void {
			//trace('onCloseConection');
		}
		
		private function onRestoreFromSleep(e:SysMonEvent):void {
			//trace('onRestoreFromSleep');
			lastStatus = null;
			reconnect();
		}
		
		private function onError(e:Event = null):void {
			//Log.logRetry('PING : ERROR', Log.NORMAL);
			lastTime = _reconnectDelay - timeOperation.time;
			timeOperation.destroy();
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
				ping();
			}
		}
		
		private function onComplete(e:Event = null):void {
			_currentRetries = 0;
			if (lastStatus != NetMonEvent.HTTP_ENABLE) {
				Log.logRetry('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network available', Log.NORMAL);
				dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_ENABLE));
			}
			lastStatus = NetMonEvent.HTTP_ENABLE;
			lastTime = _reconnectDelay - timeOperation.time;
			timeOperation.destroy();
			ping();
		}
		
		private function ping():void {
			clearTimeout(pingTimout);
			var delta:int = 0;
			if (timeOperation) {
				delta = _reconnectDelay - timeOperation.time;
			}
			
			if ( delta > 0 ) {
				pingTimout = setTimeout(doPing,  delta);
			}else {
				doPing();
			}
		}
		
		private function doPing():void {
			clearTimeout(pingTimout);
			timeOperation = new TimeOperation(_origin, Settings.PING_OPEARTION_TIMEOUT);
			timeOperation.setURL();
			timeOperation.addEventListener(OperationEvent.RESULT, onComplete);
			timeOperation.addEventListener(OperationEvent.FAULT, onError);
			connection.sendOperation(timeOperation);
		}
		
		public function start():void {
			//trace(this, 'start : ' + _isRunning);
			if (_isRunning) return;
			clearTimeout(pingTimout);
			_currentRetries = 0;
			lastStatus = null;
			reconnect();
			sysMon.start();
			_isRunning = true;
		}
		
		private function reconnect():void {
			stop();
			ping();
		}
		
		public function stop():void {
			_isRunning = false;
			lastStatus = null;
			sysMon.stop();
			connection.close();
			clearInterval(interval);
			clearTimeout(pingTimout);
		}
		
		public function destroy():void {
			if (_destroyed) return;
			stop();
			sysMon.stop();
			sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			sysMon = null;
			
			/*loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);*/
			try {
				loader.close();
			}catch (err:Error) {}
			loader = null;
			_destroyed = true;
			
			
			connection.close();
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
		
		public function get maxRetries():uint {
			return _maxRetries;
		}
		
		public function set maxRetries(value:uint):void {
			_maxRetries = value;
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