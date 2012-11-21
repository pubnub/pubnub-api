package com.pubnub.environment {
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	[Event(name="restore_from_sleep", type="com.pubnub.environment.SysMonEvent")]
	public class SysMon extends EventDispatcher {
		
		private var interval:int;
		private const TIMEOUT:int = 1000;
		private var lastTime:Number;
		private var _restoreFromSleep:Boolean;
		
		public function SysMon() {
			super(null);
			init();
		}
		
		public function start():void {
			stop();
			lastTime = getTimer();
			interval = setInterval(ping, TIMEOUT);
		}
		
		public function stop():void {
			clearInterval(interval);
		}
		
		private function init():void {
			
		}
		
		private function ping():void {
			var time:Number = getTimer();
			if ( (time - lastTime) > 2 * TIMEOUT) {
				if (_restoreFromSleep == false) {
					_restoreFromSleep = true;
					dispatchEvent(new SysMonEvent(SysMonEvent.RESTORE_FROM_SLEEP));
				}
			}else {
				_restoreFromSleep = false
			}
			lastTime = time;
		}
	}
}