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
		
		
		static private var __instance:Pn;
		static private const MILLON:Number = 1000000;
		static private const INIT_OPERATION:String = 'init';
		static private const HISTORY_OPERATION:String = 'history';
		
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
			var operation:Operation = getOperation(INIT_OPERATION);
			operation.send( { url:url, channel:"system", uid:INIT_OPERATION, sessionUUID : _sessionUUID } );
			operation.addEventListener(OperationEvent.RESULT, onInitComplete);
			operation.addEventListener(OperationEvent.FAULT, onInitError);
			
			var historyOperation:HistoryOperation = new HistoryOperation();
			operations[HISTORY_OPERATION] = historyOperation;
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
			//trace('startTimeToken : ' + startTimeToken);
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
				dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, 
												{ result: [ -1, 'AlreadyConnected'] },
												channel, 
												OperationStatus.ERROR ));
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
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, channel.name, OperationStatus.ERROR));
		}
		
		private function onSubscribeDisconnect(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, channel.name, OperationStatus.DISCONNECT));
		}
		
		private function onSubscribeData(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, channel.name, OperationStatus.DATA));
		}
		
		private function onSubscribeConnect(e:ChannelEvent):void {
			var channel:Channel = e.target as Channel;
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, channel.name, OperationStatus.CONNECT));
		}
		
		
		public function detailedHistory(args:Object):void {
			//throwInit();
			if (args.start == undefined) {
				args.start = startTimeToken;
			}
			if (args.end == undefined) {
				args.end = startTimeToken + 100 * MILLON;
			}
			if (args.count) {
				args.count = 100;
			}
			if (args.reverse == undefined) {
				args.reverse = false;
			}
			var historyOperation:HistoryOperation = getOperation(HISTORY_OPERATION) as HistoryOperation;
			historyOperation.channel = args.channel;
			historyOperation.subKey = _subscribeKey;
			historyOperation.origin = origin;
			historyOperation.cipherKey = cipherKey;
			historyOperation.addEventListener(OperationEvent.RESULT, onHistoryResult);
			historyOperation.addEventListener(OperationEvent.FAULT, onHistoryFault);
			historyOperation.send(args);
		}
		
		private function onHistoryResult(e:OperationEvent):void {
			//trace('onHistoryResult');
			dispatchEvent(new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.DATA));
		}
		
		private function onHistoryFault(e:OperationEvent):void {
			//trace('onHistoryFault');
			dispatchEvent(new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.ERROR));
		}
		
		public function detailedHistory2(args:Object):void {
			//throwInit();
			var startTime:int = 0
			if (args.start != undefined) {
				startTime = args.start;
			}
			
			var endTime:int = 100;
			if (args.end != undefined) {
				endTime = args.end;
			}
			var correctedArgs:Object = { };
			for (var name:String in args) {
				correctedArgs[name] = args[name]
			}
			correctedArgs.start = startTimeToken + startTime * MILLON;
			correctedArgs.end = startTimeToken + endTime * MILLON;
			detailedHistory(correctedArgs);
			//trace(correctedArgs.start, correctedArgs.end, (correctedArgs.end - correctedArgs.start) / 1000000);
		}
		
		public function destroy():void {
			dispose();
		}
		
		public function dispose():void {
			getOperation(HISTORY_OPERATION).close();
			getOperation(INIT_OPERATION).close();
			for each(var channel:Channel  in subscribes) {
				channel.dispose();
			}
		}
		
		private function throwInit():void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet"); 
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
				dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, [-1, 'Channel not found'], channel, OperationStatus.ERROR));
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
