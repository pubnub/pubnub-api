package com.pubnub {
	
	import com.pubnub.connection.*;
	import com.pubnub.environment.*;
	import com.pubnub.log.*;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import com.pubnub.subscribe.*;
	import flash.errors.*;
	import flash.events.*;
	import flash.system.Security;
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
        private var operationsFactory:Dictionary;
		
        private var subscribeConnection:Subscribe;
		
		private var _origin:String;
		private var _ssl:Boolean;
		private var _publishKey:String = "demo";
		private var _subscribeKey:String = "demo";
		private var secretKey:String = "";
		private var cipherKey:String = "";
		private var _checkReconnect:Boolean;
		
        private var _sessionUUID:String = "";
		private var ori:Number = Math.floor(Math.random() * 9) + 1;
		private var environment:Environment;
		
		static pn_internal var syncConnection:SyncConnection;
		
		public function Pn() {
			if (__instance) throw new IllegalOperationError('Use [Pn.instance] getter');
			setup();
		}
		
		private function setup():void {
			
			operationsFactory = new Dictionary();
			operationsFactory[INIT_OPERATION] = 	createInitOperation; 
			operationsFactory[PUBLISH_OPERATION] = 	createPublishOperation; 
			operationsFactory[HISTORY_OPERATION] = 	createDetailedHistoryOperation; 
			operationsFactory[TIME_OPERATION] = 	createTimeOperation; 
			syncConnection = new SyncConnection(Settings.OPERATION_TIMEOUT);
			
			environment = new Environment(origin);
			environment.addEventListener(EnvironmentEvent.SHUTDOWN, 	onEnvironmentShutdown);
			environment.addEventListener(NetMonEvent.HTTP_ENABLE, 		onEnvironmentHttpEnable);
			environment.addEventListener(NetMonEvent.HTTP_DISABLE, 		onEnvironmentHttpDisable);
		}
		
		private function onEnvironmentHttpDisable(e:NetMonEvent):void {
			_checkReconnect = true;
			if (subscribeConnection) {
				subscribeConnection.networkEnabled = false;
			}
			dispatchEvent(e);
		}
		
		private function onEnvironmentHttpEnable(e:NetMonEvent):void {
			//trace('onEnvironmentHttpEnable : ' +  Settings.RESUME_ON_RECONNECT)
			syncConnection.networkEnabled = true;
			if (subscribeConnection) {
				subscribeConnection.networkEnabled = true;
				/*if (_checkReconnect && Settings.RESUME_ON_RECONNECT == false) {
					trace('RECONNECT');
					subscribeConnection.reconnect();
				}*/
			}
			
			if (_initialized == false) {
				// Loads start time token
				doInit();
			}
			_checkReconnect = false;
			dispatchEvent(e);
		}
		
		private function doInit():void {
			var operation:Operation = createOperation(INIT_OPERATION)
			syncConnection.sendOperation(operation);
		}
		
		private function onEnvironmentShutdown(e:EnvironmentEvent):void {
			shutdown(Errors.NETWORK_LOST);
		}
		
		private function shutdown(reason:String = ''):void {
			// define last params
			var channels:String = 'no channels';
			var lastToken:String = null;
			if (subscribeConnection) {
				if (subscribeConnection.channels) {
					channels = subscribeConnection.channels.join(',');
				}
				lastToken = subscribeConnection.lastToken;
			}
			_checkReconnect = false;
			syncConnection.close();
			if (subscribeConnection) subscribeConnection.close();
			environment.stop();
			_initialized = false;
			Log.logRetry('Shutdown', Log.WARNING);
			
			dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE));
			//dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, null, [0, Errors.NETWORK_LOST, channels, lastToken]));
			dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, null, [0, reason, channels, lastToken]));
		}
		
		private function createOperation(type:String, args:Object = null):Operation {
			var op:Operation = operationsFactory[type].call(null, args);
			return op;
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
			if (_initialized) {
				shutdown('re-init');
			}
			_initialized = false;
			ori = Math.floor(Math.random() * 9) + 1;
			initKeys(config);
            _sessionUUID = PnUtils.getUID();
			if (subscribeConnection) {
				subscribeConnection.sessionUUID = _sessionUUID;
			}
			
			//start Environment service (wait first HTTP_ENABLE event)
			environment.start();
			
			subscribeConnection ||= new Subscribe();
			subscribeConnection.addEventListener(SubscribeEvent.CONNECT, 	onSubscribe);
			subscribeConnection.addEventListener(SubscribeEvent.DATA, 		onSubscribe);
			subscribeConnection.addEventListener(SubscribeEvent.DISCONNECT, onSubscribe);
			subscribeConnection.addEventListener(SubscribeEvent.ERROR, 		onSubscribe);
			subscribeConnection.addEventListener(SubscribeEvent.PRESENCE, 	onSubscribe);
			subscribeConnection.origin = _origin;
			subscribeConnection.subscribeKey = _subscribeKey;
			subscribeConnection.sessionUUID = _sessionUUID;
			subscribeConnection.cipherKey = cipherKey;
		}
		
		private function createInitOperation(args:Object = null):Operation {
			var init:TimeOperation = new TimeOperation(_origin);
			init.addEventListener(OperationEvent.RESULT, onInitComplete);
			init.addEventListener(OperationEvent.FAULT, onInitError);
			init.setURL();
			return init;
		}
		
		private function onInitComplete(event:OperationEvent):void {
			var result:Object = event.data;
			_initialized = true;
			environment.start();
			dispatchEvent(new PnEvent(PnEvent.INIT,  result[0]));
		}
		
		private function onInitError(event:OperationEvent):void {
			dispatchEvent(new PnEvent(PnEvent.INIT_ERROR, Errors.INIT_OPERATION_ERROR));
		}
		/*---------------SUBSCRIBE---------------*/
		public static function subscribe(channel:String, token:String = null):void{
			instance.subscribe(channel, token);
		}
		
		/**
		 * 
		 * @param	channel for MX subcribe use "ch1,ch2,ch3,ch4"
		 */
		public function subscribe(channel:String, token:String = null):void {
			throwInit();
			subscribeConnection.subcribe(channel, token);
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
				
				case SubscribeEvent.PRESENCE:
					status = OperationStatus.DISCONNECT;
					dispatchEvent(new PnEvent(PnEvent.PRESENCE, e.data, e.data.channel));
					return;
				break;
			
				default: status = OperationStatus.ERROR;		
			}
			dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, e.data.channel, status));
		}
		
		/*---------------UNSUBSCRIBE---------------*/
		public static function unsubscribe(channel:String):void {             
			instance.unsubscribe(channel);
		}

		public function unsubscribe(channel:String):void {
			throwInit(); 
			subscribeConnection.unsubscribe(channel);
		}
		
		public static function unsubscribeAll():void {
			instance.unsubscribeAll();
		}
		
		public function unsubscribeAll():void {
			throwInit();
			if(subscribeConnection) subscribeConnection.unsubscribeAll();
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
		}
		
		private function onHistoryFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
		}
		
		private function createDetailedHistoryOperation(args:Object = null):Operation{
			var history:HistoryOperation = new HistoryOperation(origin);
			history.cipherKey = cipherKey;
			history.setURL(null, args);
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
			syncConnection.sendOperation(operation);
		}
		
		private function onPublishFault(e:OperationEvent):void {
			//trace('onPublishFault : ' + e.target.url);
			var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.ERROR);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
		}
		
		private function onPublishResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.DATA);
			pnEvent.operation = e.target as Operation;
			dispatchEvent(pnEvent);
		}
		
		private function createPublishOperation(args:Object = null):Operation{
			var publish:PublishOperation = new PublishOperation(origin);
			publish.cipherKey = cipherKey;
			publish.secretKey = secretKey;
			publish.publishKey = _publishKey;
			publish.subscribeKey = _subscribeKey;
			publish.setURL(null, args);
			publish.addEventListener(OperationEvent.RESULT, onPublishResult);
			publish.addEventListener(OperationEvent.FAULT, onPublishFault);
			return publish;
		}
		
		
		/*---------------TIME---------------*/
		public static function time():void {
			instance.time();
		}
		
		public function time():void {
			//throwInit();
			var operation:Operation = createOperation(TIME_OPERATION);
			operation.addEventListener(OperationEvent.RESULT, onTimeResult);
			operation.addEventListener(OperationEvent.FAULT, onTimeFault);
			syncConnection.sendOperation(operation);
		}
		
		private function onTimeFault(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.TIME, e.data, null, OperationStatus.ERROR);
			dispatchEvent(pnEvent);
		}
		
		private function onTimeResult(e:OperationEvent):void {
			var pnEvent:PnEvent = new PnEvent(PnEvent.TIME, e.data, null, OperationStatus.DATA);
			dispatchEvent(pnEvent);
		}
		
		private function createTimeOperation(args:Object = null):Operation{
			var time:TimeOperation = new TimeOperation(origin);
			time.addEventListener(OperationEvent.RESULT, onTimeResult);
			time.addEventListener(OperationEvent.FAULT, onTimeFault);
			time.setURL();
			return time;
		}
		
		public static function getSubscribeChannels():Array{
			if (instance.subscribeConnection) {
				return instance.subscribeConnection.channels;
			}else {
				return null;
			}
		}
		
		private function initKeys(config:Object):void {
			_ssl = config.ssl;
			origin = config.origin;
			//trace('origin : ' + origin);
			if(config.publish_key)
				_publishKey = config.publish_key;
			
			if(config.sub_key)
				_subscribeKey = config.sub_key;
			
			if(config.secret_key)
				secretKey = config.secret_key;
			
			if(config.cipher_key)
				cipherKey = config.cipher_key;
		}
		
		private function throwInit():void {
			if (!_initialized) throw new IllegalOperationError("[PUBNUB] Not initialized yet"); 
		}
		
		public function destroy():void {
			shutdown();
			
			syncConnection.destroy();
			syncConnection = null;
			
			subscribeConnection.destroy();
			subscribeConnection = null;
			
			environment.destroy();
			environment.removeEventListener(EnvironmentEvent.SHUTDOWN, 		onEnvironmentShutdown);
			environment.removeEventListener(EnvironmentEvent.RECONNECT, 	onEnvironmentHttpEnable);
			environment.removeEventListener(NetMonEvent.HTTP_DISABLE, 		onEnvironmentHttpDisable);
			environment = null;
			
			subscribeConnection = null;
			_initialized = false;
			__instance = null;
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
			if (subscribeConnection) {
				subscribeConnection.origin = _origin;
			}
			environment.origin = _origin;
		}
		
		public function get ssl():Boolean {
			return _ssl;
		}
	}
}
