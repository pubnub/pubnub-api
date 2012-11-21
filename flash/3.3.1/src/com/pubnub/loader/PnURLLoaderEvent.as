package com.pubnub.loader {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class PnURLLoaderEvent extends Event {
		
		
		public static const COMPLETE:String = 'PnURLLoaderEvent.complete';
		public static const ERROR:String = 'PnURLLoaderEvent.error';
		
		private var _data:Object;
		
		public function PnURLLoaderEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this._data = data;
		} 
		
		public override function clone():Event { 
			return new PnURLLoaderEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("PnURLLoaderEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object {
			return _data;
		}
	}
}