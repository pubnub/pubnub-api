/**
 * Author: WikiFlashed
 * Released under: MIT or whatever license allowed by PubNub.
 * Use of this file at your own risk. WikiFlashed holds no responsibility or liability to what you do with this.
 */
package com.pubnub {
	
	import com.pubnub.channel.*;
	import com.pubnub.events.*;
	import com.pubnub.operation.*;
	import flash.errors.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * PubNub Static Class
	 * 
	 * This should allow creating threads of listeners to each individual channel
	 * 
	 * @author Fan
	 */
	[Event(name="initError", type="com.pubnub.PnEvent")]
	[Event(name="init", type="com.pubnub.PnEvent")]
	public class Pn extends EventDispatcher {
		
		public var origin:String = "http://pubsub.pubnub.com";          
		public var ssl:Boolean = false;
		public var interval:Number = 0.1;
		
		
		private static var __instance:Pn;
		private var _initialized:Boolean = false;         
		
		private var operations:Dictionary;
        private var subscribes:Dictionary;
		
		
		
		private var _publishKey:String = "demo";
		private var _subscribeKey:String = "demo";
		private var secretKey:String = "";
		private var cipherKey:String = "";
		
		private var startTimeToken:Number = 0;
        private var _sessionUUID:String = "";
        
		private var ori:Number = Math.floor(Math.random() * 9) + 1;
        
		public function Pn() {
			if (__instance) throw new IllegalOperationError('Use [Pn.instance] getter');
		}
		
		static public function get instance():Pn{
			__instance ||= new Pn();
			return __instance;
		}
		
		static public function  init(config:Object):void {
			instance.init(config);
		}
		
		
		/**
		 * origin = https:// or http://
		 * @param config
		 */
		public function init(config:Object):void {
			if (_initialized) {
				unsubscribeAll();
			}
			_initialized = false;
			operations = new Dictionary();
			subscribes = new Dictionary();
			initKeys(config);
            _sessionUUID = PnUtils.getUID();
			var url:String = origin + "/" + "time" + "/" + 0;
			// Loads Time Token
			var operation:Operation = getOperation('init');
			operation.send( { url:url, channel:"system", uid:"init", sessionUUID : _sessionUUID } );
			operation.addEventListener(OperationEvent.RESULT, onInitComplete);
			operation.addEventListener(OperationEvent.FAULT, onInitError);
		}
		
		private function hasChannel(name:String):Boolean {
			return subscribes[name];
		}
		
		private function getChannel(name:String):Channel {
			var result:Channel = subscribes[name] || new Channel();
			subscribes[name] = result;
			return result;
		}
		
		private function initKeys(config:Object):void {
			if(config.ssl && config.origin){
				origin = "https://" + config.origin;
			}
			else if (config.origin){
				origin = "http://" + config.origin;
			}
			
			if(config.publish_key){
				_publishKey = config.publish_key;
			}
			
			if(config.sub_key){
				_subscribeKey = config.sub_key;
			}
			
			if(config.secret_key){
				secretKey = config.secret_key;
			}
			
			if(config.cipher_key){
				cipherKey = config.cipher_key;
			}
			
			if (config.push_interval){
				interval = config.push_interval;
			}
		}
		
		private function onInitComplete(event:OperationEvent):void {
			var result:Object = event.data;
			startTimeToken = result[0];
			//startTimeToken = 0;
			_initialized = true;
			dispatchEvent(new PnEvent(PnEvent.INIT, startTimeToken));
		}
		
		private function onInitError(event:OperationEvent):void {
			dispatchEvent(new PnEvent(PnEvent.INIT_ERROR));
		}
		
		
		public static function subscribe(channel:String):void{
			instance.subscribe(channel);
		}
		
		public function subscribe(channel:String):void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet");
			var subChannel:Channel = getChannel(channel);
			if (subChannel.connected) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.SUBSCRIBE, 
												channel, 
												SubscribeStatus.ERROR, 
												{ result: [ -1, 'AlreadyConnected'] } ));
				return;
			}
			
			
			subChannel.origin = origin;
			subChannel.subscribeKey = subscribeKey;
			subChannel.sessionUUID = sessionUUID;
			subChannel.cipherKey = cipherKey;
			subChannel.subscribe(channel);
			subChannel.addEventListener(ChannelEvent.CONNECT, onSubscribeConnect);
			subChannel.addEventListener(ChannelEvent.DATA, onSubscribeData);
			subChannel.addEventListener(ChannelEvent.DISCONNECT, onSubscribeDisconnect);
			subChannel.addEventListener(ChannelEvent.ERROR, onSubscribeError);
		}
		
		private function onSubscribeError(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new SubscribeEvent(SubscribeEvent.SUBSCRIBE, channel.name, SubscribeStatus.ERROR, e.data));
		}
		
		private function onSubscribeDisconnect(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new SubscribeEvent(SubscribeEvent.SUBSCRIBE, channel.name, SubscribeStatus.DISCONNECT, e.data));
		}
		
		private function onSubscribeData(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new SubscribeEvent(SubscribeEvent.SUBSCRIBE, channel.name, SubscribeStatus.DATA, e.data));
		}
		
		private function onSubscribeConnect(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new SubscribeEvent(SubscribeEvent.SUBSCRIBE, channel.name, SubscribeStatus.CONNECT, e.data));
		}
		
		private function getOperation(type:String):Operation {
			var result:Operation = operations[type] || new Operation();
			operations[type] = result;
			return result;
		}
		
		public function get sessionUUID():String {
			return _sessionUUID;
		}
		
		public function get publishKey():String {
			return _publishKey;
		}
		
		public function get subscribeKey():String {
			return _subscribeKey;
		}
		
		public function get initialized():Boolean {
			return _initialized;
		}
		
		/**
		 * UnSubscription Wrapper
		 * @param  channel
		 */
		public static function unsubscribe(channel:String):void {             
			instance.unsubscribe(channel);
		}

		/**
		 * UnSubscribes to a channel
		 * @param channel
		 */
		public function unsubscribe(channel:String):void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet");   
			if (hasChannel(channel)) {
				var subChannel:Channel = getChannel(channel);
				subChannel.unsubscribe(channel);
			}else {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.SUBSCRIBE, channel, SubscribeStatus.ERROR, [-1, 'Channel not found']));
			}
		}
		
		public static function unsubscribeAll():void {
			instance.unsubscribeAll();
		}
		
		public function unsubscribeAll():void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet");
			for each(var i:Channel  in subscribes) {
				unsubscribe(i.name);
			}
		}
	}
}
