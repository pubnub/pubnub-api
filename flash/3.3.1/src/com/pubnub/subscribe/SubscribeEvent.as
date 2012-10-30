package com.pubnub.subscribe {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class SubscribeEvent extends Event {
		
		public static const DATA:String = 'ChannelEvent.data';
		public static const CONNECT:String = 'ChannelEvent.connect';
		public static const DISCONNECT:String = 'ChannelEvent.disconnect';
		public static const ERROR:String = 'ChannelEvent.error';
		
		private var _data:Object;
		
		public function SubscribeEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this._data = data;
		} 
		
		public override function clone():Event { 
			return new SubscribeEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("SubscribeEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object {
			return _data;
		}
		
	}
	
}