package com.pubnub.environment {
	import com.pubnub.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[Event(name="shutdown", type="com.pubnub.environment.EnvironmentEvent")]
	public class Environment extends EventDispatcher {
		private var _origin:String;
		private var netMon:NetMon;
		private var sysMon:SysMon;
		private var _netwotkEnabled:Boolean;
		private var lastHTTPDisabledTime:int = 0;
		private var maxTimeout:int;
		
		public function Environment(origin:String) {
			super();
			_origin = origin;
			init();
		}
		
		public function start():void {
			netMon.start();
			sysMon.start();
			lastHTTPDisabledTime = 0;
		}
		
		public function stop():void {
			netMon.stop();
			sysMon.stop();
		}
		
		public function destroy():void {
			stop();
			
			netMon.destroy();
			netMon.removeEventListener(NetMonEvent.HTTP_DISABLE, 	onHTTPDisable);
			netMon.removeEventListener(NetMonEvent.HTTP_ENABLE, 	onHTTPEnable);
			netMon.removeEventListener(NetMonEvent.MAX_RETRIES, 	onMaxRetries);
			netMon = null;
			
			sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			sysMon = null;
		}
		
		private function init():void {
			netMon = new NetMon();
			netMon.reconnectDelay = Settings.PING_OPERATION_INTERVAL;
			netMon.maxRetries = 	Settings.MAX_RECONNECT_RETRIES;
			netMon.addEventListener(NetMonEvent.HTTP_DISABLE, onHTTPDisable);
			netMon.addEventListener(NetMonEvent.HTTP_ENABLE, onHTTPEnable);
			netMon.addEventListener(NetMonEvent.MAX_RETRIES, onMaxRetries);
			
			sysMon = new SysMon();
			sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			
			maxTimeout = Settings.MAX_RECONNECT_RETRIES * Settings.PING_OPERATION_INTERVAL;
		}
		
		private function onMaxRetries(e:NetMonEvent):void {
			dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_RETRIES_EXCEEDED));
		}
		
		private function onRestoreFromSleep(e:SysMonEvent):void {
			if (e.timeout > maxTimeout) {
				dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_TIMEOUT_EXCEEDED));
			}else {
				dispatchEvent(new EnvironmentEvent(EnvironmentEvent.RECONNECT));
			}
		}
		
		private function onHTTPEnable(e:NetMonEvent):void {
			if (lastHTTPDisabledTime) {
				var time:int = getTimer();
				if ( (time - lastHTTPDisabledTime) > maxTimeout) {
					_netwotkEnabled = false;
					dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_TIMEOUT_EXCEEDED));
				}else {
					_netwotkEnabled = true;
					dispatchEvent(new EnvironmentEvent(EnvironmentEvent.RECONNECT));
				}
				lastHTTPDisabledTime = 0;
			}
		}
		
		private function onHTTPDisable(e:NetMonEvent):void {
			lastHTTPDisabledTime = getTimer();
			_netwotkEnabled = false;
			dispatchEvent(e);
		}
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
			netMon.origin = value;
		}
		
		public function get netwotkEnabled():Boolean {
			return _netwotkEnabled;
		}
	}
}