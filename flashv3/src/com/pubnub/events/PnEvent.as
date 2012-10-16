package com.pubnub.events{
	import flash.events.Event;
	
	/**
	 * Pub Nub Event
	 * @author Maxim Firsov
	 */
	public class PnEvent extends Event {
		
		// init Pubnub
		public static const INIT:String = "init";
		public static const INIT_ERROR:String = "initError";
		
		// subscribe channel was set up
		public static const SUBSCRIBE:String = "subscribe";
		// subscribe channel recieve data
		public static const SUBSCRIBE_DATA:String = "subscribeData";
		//subscribe channel was disconnect
		public static const UNSUBSCRIBE:String = "Unsubscribe";
		
		
		public static const PUBLISH:String = "Publish";
		
        public static const PRESENCE:String = "Presence";
        public static const HERE_NOW:String = "HereNow";
		public static const HISTORY:String = "History";
		public static const DETAILED_HISTORY:String = "DetailedHistory";
		public static const TIME:String="Time";
		
		public static const ERROR:String = "Error";
		
		
		private var _data:Object;
		
		public function PnEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			_data = data;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new PnEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("PnEvent", "type", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object {
			return _data;
		}
	}
}
