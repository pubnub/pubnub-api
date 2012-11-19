package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class SysMonEvent extends Event {
		
		public static const RESTORE_FROM_SLEEP:String = 'restore_from_sleep';
		
		public function SysMonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new SysMonEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("SysMonEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}