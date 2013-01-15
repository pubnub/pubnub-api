package com.pubnub.operation {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class OperationEvent extends Event {
		
		public static const RESULT:String = 'OperationEvent.result';
		public static const FAULT:String = 'OperationEvent.fault';
		public static const TIMEOUT:String = 'OperationEvent.timeout';
		
		private var _data:Object;
		
		public function OperationEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			_data = data;	
		} 
		
		public override function clone():Event { 
			return new OperationEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("OperationEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object {
			return _data;
		}
	}
}