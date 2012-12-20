package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class SysMonEvent extends Event {
		
		public static const RESTORE_FROM_SLEEP:String = 'restore_from_sleep';
		
		private var _timeout:int = 0;
		
		public function SysMonEvent(type:String, timeout:int = 0) { 
			super(type);
			_timeout = timeout;
		} 
		
		public override function clone():Event { 
			return new SysMonEvent(type, timeout);
		} 
		
		public override function toString():String { 
			return formatToString("SysMonEvent", "type", "timeout", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get timeout():int {
			return _timeout;
		}
		
	}
	
}