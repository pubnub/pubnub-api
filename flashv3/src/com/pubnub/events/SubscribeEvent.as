package com.pubnub.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class SubscribeEvent extends Event {
		
		public static const SUBSCRIBE:String = 'SubscribeEvent.subscribe';
		
		private var _status:String;
		private var _channel:String;
		private var _data:Object;
		
		public function SubscribeEvent(type:String, channel:String, status:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) { 
			_channel = channel;
			_status = status;
			_data = data;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new SubscribeEvent(type, channel, status,data ,bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("SubscribeEvent", "type", "channel", "status", "data" , "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get status():String {
			return _status;
		}
		
		public function get channel():String {
			return _channel;
		}
		
		public function get data():Object {
			return _data;
		}
		
	}
}