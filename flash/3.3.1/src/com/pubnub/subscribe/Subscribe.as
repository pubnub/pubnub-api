package com.pubnub.subscribe {
	import com.pubnub.json.PnJSON;
	import com.pubnub.operation.OperationStatus;
	import com.pubnub.PnEvent;
	import flash.events.IEventDispatcher;
	import org.casalib.events.RemovableEventDispatcher;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Subscribe extends RemovableEventDispatcher {
		private var _channelName:String;
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		protected var _origin:String;
		protected var _connectionUID:String;
		
		protected var subscribe:SubscribeChannel;
		protected var presence:PresenceChannel
		
		
		public function Subscribe() {
			super(null);
			init();
		}
		
		private function init():void {
			subscribe = new SubscribeChannel();
			subscribe.addEventListener(SubscribeEvent.CONNECT, 		dispatchEvent);
			//subscribe.addEventListener(SubscribeEvent.CONNECT, 		test);
			subscribe.addEventListener(SubscribeEvent.DATA, 		dispatchEvent);
			subscribe.addEventListener(SubscribeEvent.DISCONNECT, 	dispatchEvent);
			subscribe.addEventListener(SubscribeEvent.ERROR, 		dispatchEvent);
			
			presence = new PresenceChannel();
			presence.addEventListener(SubscribeEvent.DATA, 		dispatchEventPresence);
		}
		
		private function test(e:*):void {
			trace('dasdasdasdasd');
		}
		
		private function dispatchEventPresence(e:SubscribeEvent):void {
			var str:String = PnJSON.stringify(e.data.result);
			dispatchEvent(new PnEvent(PnEvent.PRESENCE, str, presence.channelName, OperationStatus.DATA));
		}
		
		public function connect(channelName:String):void {
			trace('connect : ' + channelName);
			trace('connect : ' + _origin);
			trace('connect : ' + subscribeKey);
			trace('connect : ' + sessionUUID);
			trace('connect : ' + cipherKey);
			_channelName = channelName;
			
			subscribe.origin = 			presence.origin = 		_origin;
			subscribe.subscribeKey = 	presence.subscribeKey =	subscribeKey;
			subscribe.sessionUUID = 	presence.sessionUUID =	sessionUUID;
			subscribe.cipherKey = 		presence.cipherKey = 	cipherKey;
			subscribe.connect(channelName);
			
			presence.connectionUID = subscribe.connectionUID;
			presence.connect(channelName);
		}
		
		public function unsubscribe(channelName:String):void {
			subscribe.unsubscribe();
			presence.unsubscribe();
		}
		
		override public function destroy():void {
			if (_isDestroyed) return;
			super.destroy();
			subscribe.removeEventListener(SubscribeEvent.CONNECT, 		dispatchEvent);
			subscribe.removeEventListener(SubscribeEvent.DATA, 			dispatchEvent);
			subscribe.removeEventListener(SubscribeEvent.DISCONNECT, 	dispatchEvent);
			subscribe.removeEventListener(SubscribeEvent.ERROR, 		dispatchEvent);
			subscribe.destroy();
			
			presence.destroy();
			presence.removeEventListener(SubscribeEvent.DATA, 		dispatchEventPresence);
			
			presence = null;
			subscribe = null;
		}
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
		}
		
		public function get channelName():String {
			return _channelName;
		}
		
		public function get connected():Boolean { return subscribe && subscribe.connected; }
	}
}