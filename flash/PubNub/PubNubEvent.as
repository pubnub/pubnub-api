package PubNub
{
	import flash.events.Event;
	
	/**
	 * Pub Nub Event
	 * @author Fan Di
	 */
	public class PubNubEvent extends Event 
	{
		public static const SUBSCRIBE_CONNECTED:String = "SubscribeConnected";
		public static const PUBLISH:String = "Publish";
		public static const SUBSCRIBE:String = "Subscribe";
        public static const PRESENCE:String = "Presence";
		public static const HISTORY:String = "History";
		public static const TIME:String="Time";
		public static const UNSUBSCRIBE:String = "Unsubscribe";
		public static const ERROR:String = "Error";
		public static const INIT:String = "Init";
		public var data:Object;
		
		public function PubNubEvent(type:String, d:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			data = d;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new PubNubEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PubNubEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
