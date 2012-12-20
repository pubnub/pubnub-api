package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class EnvironmentEvent extends Event {
		
		public static const SHUTDOWN:String = 'shutdown';
		public static const RECONNECT:String = 'reconnect';
		private var _reason:String;
		
		public function EnvironmentEvent(type:String, reason:String = null) { 
			super(type);
			_reason = reason;
		} 
		
		public override function clone():Event { 
			return new EnvironmentEvent(type, reason);
		} 
		
		public override function toString():String { 
			return formatToString("EnvironmentEvent", "type", "reason", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get reason():String {
			return _reason;
		}
	}
}