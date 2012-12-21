package com.pubnub.environment {
	import com.pubnub.Errors;
	import com.pubnub.Settings;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[Event(name="shutdown", type="com.pubnub.environment.EnvironmentEvent")]
	public class Environment extends EventDispatcher {
		private var _origin:String;
		private var netMon:NetMon;
		private var sysMon:SysMon;
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
			netMon.removeEventListener(NetMonEvent.HTTP_DISABLE, onHTTPDisable);
			netMon.removeEventListener(NetMonEvent.HTTP_ENABLE, onHTTPEnable);
			netMon.removeEventListener(NetMonEvent.MAX_RETRIES, onMaxRetries);
			netMon = null;
			
			
			sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			sysMon = null;
		}
		
		private function init():void {
			netMon = new NetMon();
			netMon.reconnectDelay = 			Settings.CONNECTION_HEARTBEAT_INTERVAL;
			netMon.forceReconnectDelay = 		Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			netMon.maxForceReconnectRetries = 	Settings.MAX_RECONNECT_RETRIES;
			
			netMon.addEventListener(NetMonEvent.HTTP_DISABLE, onHTTPDisable);
			netMon.addEventListener(NetMonEvent.HTTP_ENABLE, onHTTPEnable);
			netMon.addEventListener(NetMonEvent.MAX_RETRIES, onMaxRetries);
			
			sysMon = new SysMon();
			sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
			
			maxTimeout = Settings.MAX_RECONNECT_RETRIES * Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			
			
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
					dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_TIMEOUT_EXCEEDED));
				}else {
					dispatchEvent(new EnvironmentEvent(EnvironmentEvent.RECONNECT));
				}
				lastHTTPDisabledTime = 0;
			}
		}
		
		private function onHTTPDisable(e:NetMonEvent):void {
			lastHTTPDisabledTime = getTimer();
		}
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
			netMon.origin = value;
		}
		
		
		/*protected function onNetMonitorMaxRetries(e:NetMonEvent):void {
			Log.log('onNetMonitorMaxRetries', Log.FATAL);
			unsubscribeAll([0, Errors.NETWORK_RECONNECT_MAX_RETRIES_EXCEEDED]);
		}
		
		protected function onNetMonitorHTTPDisable(e:NetMonEvent):void {
			if (_connected) {
				waitNetwork = true;
			}
		}
		
		protected function onNetMonitorHTTPEnable(e:NetMonEvent):void {
			if (_channels && _channels.length > 0) {
				if (Settings.RESUME_ON_RECONNECT) { 
					Log.logRetry('RETRY_LOGGING:RECONNECT_HEARTBEAT: re-established network connectivity. Resubscribing with timetoken:' +lastToken, Log.WARNING);
					if (lastToken) {
						doSubscribe();
					}else {
						subscribeInit();
					}	
				}
			}
		}*/
	}

}