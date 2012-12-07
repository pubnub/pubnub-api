package com.pubnub {
	
	import com.pubnub.connection.*;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import com.pubnub.subscribe.*;
	import flash.errors.*;
	import flash.events.*;
	import flash.utils.*;
	use namespace pn_internal;
	
	[Event(name="initError", type="com.pubnub.PnEvent")]
	[Event(name="init", type="com.pubnub.PnEvent")]
	public class Pn extends EventDispatcher {
		static private var __instance:Pn;
		static public const INIT_OPERATION:String = 'init';
		static public const HISTORY_OPERATION:String = 'history';
		static public const PUBLISH_OPERATION:String = 'publish';
		static public const TIME_OPERATION:String = 'time';
		
		private var _initialized:Boolean = false;         
		private var operations:/*Operation*/Array;
        private var subscribes:/*Subscribe*/Array;
        private var operationsFactory:Dictionary;
		private var _origin:String;
		private var _ssl:Boolean;
		private var _publishKey:String = "demo";
		private var _subscribeKey:String = "demo";
		private var secretKey:String = "";
		private var cipherKey:String = "";
		private var startTimeToken:Number = 0;
        private var _sessionUUID:String = "";
		private var ori:Number = Math.floor(Math.random() * 9) + 1;
		static pn_internal var syncConnection:SyncConnection;
		
		public function Pn() {
			if (__instance) throw new IllegalOperationError('Use [Pn.instance] getter');
			setup();
		}
		
		private function setup():void {
			operationsFactory = new Dictionary();
			operationsFactory[INIT_OPERATION] = 		createInitOperation; 
			operationsFactory[PUBLISH_OPERATION] = 	createPublishOperation; 
			operationsFactory[HISTORY_OPERATION] = 	createDetailedHistoryOperation; 
			operationsFactory[TIME_OPERATION] = 		createTimeOperation; 
			syncConnection = new SyncConnection(Settings.OPERATION_TIMEOUT);
		}
		
		public static  function get instance():Pn {
			__instance ||= new Pn();
			return __instance;
		}
		
		public static function  init(config:Object):void {
			instance.init(config);
		}
		
		/*------------------- INIT --------------------------------*/
		public function init(config:Object):void {
			//trace(this, 'init')
			if (_initialized) {
				dispose();
			}
			_initialized = false;
			subscribes = [];
			operations = [];
			ori = Math.floor(Math.random() * 9) + 1;
			
			initKeys(config);
            _sessionUUID = PnUtils.getUID();
			
			// Loads start time token
			var operation:Operation = createOperation(INIT_OPERATION)
			syncConnection.sendOperation(operation);
		}
		
		
		private function createInitOperation(args:Object = null):Operation{
			var init:InitOperation = new InitOperation();/*initOperation.uid = INIT_OPERATION;*/
			init.sessionUUID = _sessionUUID;
			init.origin = _origin;
			init.addEventListener(OperationEvent.RESULT, onInitComplete);
			init.addEventListener(OperationEvent.FAULT, onInitError);
			init.createURL(null);
			return init;
		}
		
		private function onInitComplete(event:OperationEvent):void {
			var result:Object = event.data;
			startTimeToken = result[0];
			_initialized = true;
			dispatchEvent(new PnEvent(PnEvent.INIT, startTimeToken));
			destroyOperation(event.target as Operation);
		}
		
		private function onInitError(event:OperationEvent):void {
			dispatchEvent(new PnEvent(PnEvent.INIT_ERROR, Errors.INIT_OPERATION_ERROR));
			destroyOperation(event.target as Operation);
		}
		
		
		/*---------------SUBSCRIBE---------------*/
		public static function subscribe(channel:String):void{
			instance.subscribe(channel);
		}
		
		public function subscribe(channel:String):void {
			throwInit();
			var subscribe:Subscribe = getSubscribe(channel);
			if (subscribe.connected) {
				dispatchEvent(new PnEvent(	PnEvent.SUBSCRIBE, { 
											result: [ -1, Errors.ALREADY_CONNECTED] },
											channel, 
											OperationStatus.ERROR ));
				return;
			}
			
			
			subscribe.origin = 			_origin;
			subscribe.subscribeKey = 	subscribeKey;
			subscribe.sessionUUID = 	sessionUUID;
			subscribe.cipherKey = 		cipherKey;
			subscribe.addEventListener(SubscribeEvent.CONNECT, 		onSubscribe);
			subscribe.addEventListener(SubscribeEvent.DATA, 		onSubscribe);
			subscribe.addEventListener(SubscribeEvent.DISCONNECT, 	onSubscribe);
			subscribe.addEventListener(SubscribeEvent.ERROR, 		onSubscribe);
			subscribe.addEventListener(PnEvent.PRESENCE, 			dispatchEvent);
			subscribe.connect(channel);
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
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, subscribe.channelName, status));
		}
		
		/*---------------UNSUBSCRIBE---------------*/
		public static function unsubscribe(channel:String):void {             
			instance.unsubscribe(channel);
		}

		public function unsubscribe(channel:String):void {
			throwInit(); 
			var subscribe:Subscribe = getSubscribeFromArray(channel);
			if (subscribe) {
				subscribe.disconnect();
			}else {
				dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, [-1, 'Channel not found'], channel, OperationStatus.ERROR));
			}
			removeSubscribeEvents(subscribe);
		}
		
		private function removeSubscribeEvents(subscribe:Subscribe):void {
			if (!subscribe) return;
			subscribe.removeEventListener(SubscribeEvent.CONNECT, onSubscribe);
			subscribe.removeEventListener(SubscribeEvent.DATA, onSubscribe);
			subscribe.removeEventListener(PnEvent.PRESENCE, dispatchEvent);
			subscribe.removeEventListener(SubscribeEvent.DISCONNECT, onSubscribe);
			subscribe.removeEventListener(SubscribeEvent.ERROR, onSubscribe);
		}
		
		private function getSubscribeFromArray(name:String):Subscribe {
			for each(var s:Subscribe in subscribes) {
				if (s.channelName == name) {
					return s;
				}
			}
			return null;
		}
		
		public static function unsubscribeAll():void {
			instance.unsubscribeAll();
		}
		
		public function unsubscribeAll():void {
			throwInit();
			for each(var i:Subscribe  in subscribes) {
				unsubscribe(i.channelName);
			}
		}
		
		/*---------------DETAILED HISTORY---------------*/
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
			var operation:Operation = createOperation(HISTORY_OPERATION, args);
			syncConnection.sendOperation(operation);
		}
		
		private function onHistoryResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.DATA);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
			destroyOperation(e.target as Operation)
		}
		
		private function onHistoryFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
			destroyOperation(e.target as Operation);
		}
		
		private function createDetailedHistoryOperation(args:Object = null):Operation{
			var history:HistoryOperation = new HistoryOperation();
			history.cipherKey = cipherKey;
			history.origin = _origin;	
			history.createURL(args);
			history.addEventListener(OperationEvent.RESULT, onHistoryResult);
			history.addEventListener(OperationEvent.FAULT, onHistoryFault);
			return history;
		}
		
		/*---------------PUBLISH---------------*/
		public static function publish(args:Object):void {
			instance.publish(args);
		}
		
		public function publish(args:Object):void {
			throwInit();
			var operation:Operation = createOperation(PUBLISH_OPERATION, args)
			//Connection.sendSync(operation);
			syncConnection.sendOperation(operation);
		}
		
		private function onPublishFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
			destroyOperation(e.target as Operation);
		}
		
		private function onPublishResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.DATA);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
			destroyOperation(e.target as Operation);
		}
		
		private function createPublishOperation(args:Object = null):Operation{
			var publish:PublishOperation = new PublishOperation();
			publish.cipherKey = cipherKey;
			publish.secretKey = secretKey;
			publish.publishKey = _publishKey;
			publish.subscribeKey = _subscribeKey;
			publish.origin = _origin;	
			publish.createURL(args);
			publish.addEventListener(OperationEvent.RESULT, onPublishResult);
			publish.addEventListener(OperationEvent.FAULT, onPublishFault);
			return publish;
		}
		
		/*---------------TIME---------------*/
		public static function time():void {
			instance.time();
		}
		
		public function time():void {
			throwInit();
			var operation:Operation = createOperation(TIME_OPERATION);
			operation.addEventListener(OperationEvent.RESULT, onTimeResult);
			operation.addEventListener(OperationEvent.FAULT, onTimeFault);
			//Connection.sendSync(operation);
			syncConnection.sendOperation(operation);
		}
		
		private function onTimeFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.TIME, e.data, null, OperationStatus.ERROR);
			dispatchEvent(pnEvent);
			destroyOperation(e.target as Operation);
		}
		
		private function onTimeResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.TIME, e.data, null, OperationStatus.DATA);
			dispatchEvent(pnEvent);
			destroyOperation(e.target as Operation);
		}
		
		private function createTimeOperation(args:Object = null):Operation{
			var time:Operation = new Operation();
			time.addEventListener(OperationEvent.RESULT, onTimeResult);
			time.addEventListener(OperationEvent.FAULT, onTimeFault);
			time.createURL({url: _origin + "/time/0"});
			return time;
		}
		
		private function createOperation(type:String, args:Object = null):Operation {
			var op:Operation = operationsFactory[type].call(null, args);
			operations.push(op);
			return op;
		}
		
		private function initKeys(config:Object):void {
			_ssl = config.ssl;
			origin = config.origin;
			if(config.publish_key)
				_publishKey = config.publish_key;
			
			if(config.sub_key)
				_subscribeKey = config.sub_key;
			
			if(config.secret_key)
				secretKey = config.secret_key;
			
			if(config.cipher_key)
				cipherKey = config.cipher_key;
		}
		
		private function destroyOperation(op:Operation):void {
			op.destroy();
			var ind:int = operations.indexOf(op);
			if (ind > -1) 
				operations.splice(ind, 1);
		}
		
		private function throwInit():void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet"); 
		}
		
		pn_internal function getSubscribe(name:String):Subscribe {
			var result:Subscribe = getSubscribeFromArray(name);
			if (!result) {
				result = new Subscribe();
				subscribes.push(result);
			}
			return result;
		}
		
		public function destroy():void {
			dispose();	
			for each(var s:Subscribe  in subscribes) {
				s.destroy();
			}
			operations = null;
			subscribes = null;
			_initialized = false;
			__instance = null;
		}
		
		public function dispose():void {
			unsubscribeAll();
			
			for each(var o:Operation in operations) {
				o.destroy();
			}
			
			for each(var s:Subscribe  in subscribes) {
				s.disconnect();
			}
			subscribes.length = 0;
			operations.length = 0;
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
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
			if (value == null || value.length == 0) throw('Origin value must be defined');
			if(_ssl){
				_origin = "https://" + value;
			}
			else {
				_origin = "http://" + value;
			}
			
			for each(var op:Operation  in operations) {
				op.origin = _origin;
			}
		}
		
		public function get ssl():Boolean {
			return _ssl;
		}
	}
}
