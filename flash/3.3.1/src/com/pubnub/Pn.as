package com.pubnub {
	
	import com.pubnub.operation.*;
	import com.pubnub.subscribe.*;
	import flash.errors.*;
	import flash.events.*;
	import flash.utils.*;
	

	[Event(name="initError", type="com.pubnub.PnEvent")]
	[Event(name="init", type="com.pubnub.PnEvent")]
	public class Pn extends EventDispatcher {
		
		static private var __instance:Pn;
		static private const INIT_OPERATION:String = 'init';
		static private const HISTORY_OPERATION:String = 'history';
		static private const PUBLISH_OPERATION:String = 'publish';
		
		private var _initialized:Boolean = false;         
		private var operations:Dictionary;
        private var subscribes:Dictionary;
		private var origin:String = "http://multiplexing.pubnub.com";
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
			ori = Math.floor(Math.random() * 9) + 1;
			initKeys(config);
            _sessionUUID = PnUtils.getUID();
			var url:String = origin + "/" + "time" + "/" + 0;
			
			// Loads start time token
			var operation:Operation = getOperation(INIT_OPERATION);
			operation.close();
			operation.send( { url:url, channel:"system", uid:INIT_OPERATION, sessionUUID : _sessionUUID } );
			operation.addEventListener(OperationEvent.RESULT, onInitComplete);
			operation.addEventListener(OperationEvent.FAULT, onInitError);
			
			operations[HISTORY_OPERATION] = new HistoryOperation();
			operations[PUBLISH_OPERATION] = new PublishOperation();
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
		}
		
		private function getOperation(type:String):Operation {
			var result:Operation = operations[type] || new Operation();
			operations[type] = result;
			
			if (type == HISTORY_OPERATION) {
				var history:HistoryOperation = result as HistoryOperation;
				history.cipherKey = cipherKey;
				history.origin = origin;	
			}else if (type == PUBLISH_OPERATION) {
				var publish:PublishOperation = result as PublishOperation;
				publish.cipherKey = cipherKey;
				publish.secretKey = secretKey;
				publish.publishKey = _publishKey;
				publish.subscribeKey = _subscribeKey;
				publish.origin = origin;	
			}
			return result;
		}
		
		private function onInitComplete(event:OperationEvent):void {
			var result:Object = event.data;
			startTimeToken = result[0];
			//startTimeToken = 0;
			_initialized = true;
			dispatchEvent(new PnEvent(PnEvent.INIT, startTimeToken));
		}
		
		private function onInitError(event:OperationEvent):void {
			dispatchEvent(new PnEvent(PnEvent.INIT_ERROR, 'Init operation error'));
		}
		
		
		public static function subscribe(channel:String):void{
			instance.subscribe(channel);
		}
		
		public function subscribe(channel:String):void {
			throwInit();
			var subscribe:Subscribe = getSubscribe(channel);
			if (subscribe.connected) {
				dispatchEvent(new PnEvent(	PnEvent.SUBSCRIBE, { 
											result: [ -1, 'AlreadyConnected'] },
											channel, 
											OperationStatus.ERROR ));
				return;
			}
			
			subscribe.origin = origin;
			subscribe.subscribeKey = subscribeKey;
			subscribe.sessionUUID = sessionUUID;
			subscribe.cipherKey = cipherKey;
			subscribe.subscribe(channel);
			subscribe.addEventListener(SubscribeEvent.CONNECT, onSubscribe);
			subscribe.addEventListener(SubscribeEvent.DATA, onSubscribe);
			subscribe.addEventListener(SubscribeEvent.DISCONNECT, onSubscribe);
			subscribe.addEventListener(SubscribeEvent.ERROR, onSubscribe);
		}
		
		private function throwInit():void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet"); 
		}
		
		private function getSubscribe(name:String):Subscribe {
			var result:Subscribe = subscribes[name] || new Subscribe();
			subscribes[name] = result;
			return result;
		}
		
		private function onSubscribe(e:SubscribeEvent):void {
			var subscribe:Subscribe = e.target as Subscribe;
			var status:String;
			switch (e.type) {
				case SubscribeEvent.CONNECT:
					status = OperationStatus.CONNECT;
				break;
			
				case SubscribeEvent.DATA:
					status = OperationStatus.DATA;
				break;
				
				case SubscribeEvent.DISCONNECT:
					status = OperationStatus.DISCONNECT;
				break;
			
				default: status = OperationStatus.ERROR;		
			}
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, subscribe.name, status));
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
			throwInit(); 
			if (hasChannel(channel)) {
				var subscribe:Subscribe = getSubscribe(channel);
				subscribe.unsubscribe(channel);
			}else {
				dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, [-1, 'Channel not found'], channel, OperationStatus.ERROR));
			}
		}
		
		private function hasChannel(name:String):Boolean {
			return subscribes[name];
		}
		
		public static function unsubscribeAll():void {
			instance.unsubscribeAll();
		}
		
		public function unsubscribeAll():void {
			throwInit();
			for each(var i:Subscribe  in subscribes) {
				unsubscribe(i.name);
			}
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
			
			var history:HistoryOperation = getOperation(HISTORY_OPERATION) as HistoryOperation;
			history.addEventListener(OperationEvent.RESULT, onHistoryResult);
			history.addEventListener(OperationEvent.FAULT, onHistoryFault);
			history.send(args);
		}
		
		private function onHistoryResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.DATA);
			pnEvent.operation = getOperation(HISTORY_OPERATION);
			dispatchEvent(pnEvent);
		}
		
		private function onHistoryFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = getOperation(HISTORY_OPERATION);
			dispatchEvent(pnEvent);
		}
		
		public static function publish(args:Object):void {
			instance.publish(args);
		}
		
		public function publish(args:Object):void {
			throwInit();
			var publishOperation:PublishOperation = getOperation(PUBLISH_OPERATION) as PublishOperation;
			publishOperation.addEventListener(OperationEvent.RESULT, onPublishResult);
			publishOperation.addEventListener(OperationEvent.FAULT, onPublishFault);
			publishOperation.send(args);
		}
		
		private function onPublishFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = getOperation(PUBLISH_OPERATION);
			dispatchEvent(pnEvent);
		}
		
		private function onPublishResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.DATA);
			pnEvent.operation = getOperation(PUBLISH_OPERATION);
			dispatchEvent(pnEvent);
		}
		
		public function destroy():void {
			dispose();
			
			// destroy all operations
			var operation:Operation = getOperation(HISTORY_OPERATION);
			operation.removeEventListener(OperationEvent.RESULT, onHistoryResult);
			operation.removeEventListener(OperationEvent.FAULT, onHistoryFault);
			
			operation = getOperation(INIT_OPERATION);
			operation.removeEventListener(OperationEvent.RESULT, onInitComplete);
			operation.removeEventListener(OperationEvent.FAULT, onInitError);
			
			operation = getOperation(PUBLISH_OPERATION);
			operation.removeEventListener(OperationEvent.RESULT, onPublishResult);
			operation.removeEventListener(OperationEvent.FAULT, onPublishFault);
			
			for each(var o:Operation in operations) {
				o.destroy();
			}
			
			for each(var s:Subscribe  in subscribes) {
				s.destroy();
			}
			
			operations = null;
			subscribes = null;
			_initialized = false;
			__instance = null;
		}
		
		public function dispose():void {
			getOperation(HISTORY_OPERATION).close();
			getOperation(INIT_OPERATION).close();
			getOperation(PUBLISH_OPERATION).close();
			for each(var s:Subscribe  in subscribes) {
				s.dispose();
			}
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
	}
}
