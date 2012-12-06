package com.pubnub.net {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class URLLoaderEvent extends Event {
		public static const COMPLETE:String = 'URLLoaderEvent.complete';
		public static const TIMEOUT:String = 'URLLoaderEvent.timeout';
		public static const ERROR:String = 'URLLoaderEvent.error';
		
		private var _data:Object;
		
		public function URLLoaderEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			_data = data;
		} 
		
		public override function clone():Event { 
			return new URLLoaderEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("URLLoaderEvent", "type", "data","bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object {
			return _data;
		}
	}
}