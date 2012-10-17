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
		
		static public function get instance():Pn {
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
			
			// 
			//var obj:Object = JSON.parse('[[{"value":,{"value":,"hello from ruby!","Hello World",{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{},{"Message":"qqqq"},{"Message":"qqqq"},{},{"Message":"abc"},{"Message":"abc"},{"Message":"qqqq"},{"some_val":"Hello World! --> ɂ顶@#$%^&*()!"},"Hello World",["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],{"some_val":"Hello World! --> ɂ顶@#$%^&*()!"},"Hello World",["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],{"some_val":"Hello World! --> ɂ顶@#$%^&*()!"},"Hello World",["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],{"Message":"\nggg"},{"some_val":"Hello World! --> ɂ顶@#$%^&*()!"},"Hello World",["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],{"Message":"\nggg"},{"Message":"qqqq"},{"Message":"qqqq"},{"Message":"qqqq"},{"Message":"qqqq"},{"Message":"qqqq"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"some_text": "Hello my World"},{"sender":"27039cde-00f1-4b43-8332-e01e8a9bee51","text":"ho"},{"sender":"27039cde-00f1-4b43-8332-e01e8a9bee51","text":"hi again"},"T3V9IUvSjcJyS08NcFleDQ==",["97kYgMRX++ScYuoEKVPfAA==","LtuUb78URtpKj9QMi38C8w==",{"food":"y68rf0\/iaqVgp\/FAhwv7Fg==","drink":"QmuzhKb\/dZqqyNKXyvm45g=="}],{"text":"hey"},"more stuff","and more",[1,"last time token"],["97kYgMRX++ScYuoEKVPfAA==","LtuUb78URtpKj9QMi38C8w==",{"food":"y68rf0\/iaqVgp\/FAhwv7Fg==","drink":"QmuzhKb\/dZqqyNKXyvm45g=="}],"T3V9IUvSjcJyS08NcFleDQ==",["97kYgMRX++ScYuoEKVPfAA==","LtuUb78URtpKj9QMi38C8w==",{"food":"y68rf0\/iaqVgp\/FAhwv7Fg==","drink":"QmuzhKb\/dZqqyNKXyvm45g=="}],"hi","hi",{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey"},{"text":"hey2"},{"text":"hey2"},{"text":"hey3"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey4"},{"text":"hey5"},{"text":"hey6"},{"text":"hey6"},{"text":"hey6"},{"text":"hey6"},"hi",{"text":"hey6"},"hi","hi","who are you?","hi","who are you?","who are you?","who are you?","who are you?","who are you?","hi","hi"],13504200325960631,13504605225815564]');
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
			throwInit();
			var channel:String = args.channel;
			var sub_key:String = args['sub-key'];
			if (channel == null || 
				channel.length == 0 ||
				sub_key == null || 
				sub_key.length == 0) {
				dispatchEvent(new PnEvent(PnEvent.DETAILED_HISTORY, [ -1, 'Channel and subKey are missing'], channel, OperationStatus.ERROR));
				return;
			}
			
			var historyOperation:HistoryOperation = getOperation(HISTORY_OPERATION) as HistoryOperation;
			historyOperation.channel = channel;
			historyOperation.sub_key = sub_key;
			historyOperation.origin = origin;
			historyOperation.cipherKey = cipherKey;
			historyOperation.addEventListener(OperationEvent.RESULT, onHistoryResult);
			historyOperation.addEventListener(OperationEvent.FAULT, onHistoryFault);
			historyOperation.send(args);
		}
		
		private function onHistoryResult(e:OperationEvent):void {
			trace('onHistoryResult : ' + e.data);
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.DATA);
			pnEvent.operation = getOperation(HISTORY_OPERATION);
			dispatchEvent(pnEvent);
		}
		
		private function onHistoryFault(e:OperationEvent):void {
			trace('onHistoryFault');
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = getOperation(HISTORY_OPERATION);
			dispatchEvent(pnEvent);
		}
		
		public function detailedHistory2(args:Object):void {
			throwInit();
			var start:String= args.start;
			var end:String = args.end;
			//trace('start : ' + start);
			if (start != null && start.length > 0) {
				args.start = startTimeToken + int(args.start) * MILLON;
			}
			
			if (end != null && end.length > 0) {
				args.end = startTimeToken + int(args.end) * MILLON;
			}
			detailedHistory(args);
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
