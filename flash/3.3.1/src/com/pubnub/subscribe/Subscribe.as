package com.pubnub.subscribe {
	import com.pubnub.*;
	import com.pubnub.connection.*;
	import com.pubnub.environment.*;
	import com.pubnub.json.*;
	import com.pubnub.log.Log;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	import org.casalib.util.StringUtil;
	use namespace pn_internal;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Subscribe extends EventDispatcher {
		static public const PNPRES_PREFIX:String = '-pnpres';
		
		
		static public const WITH_TIMETOKEN:String = 'subscribe_with_timetoken';
		static public const GET_TIMETOKEN:String = 'subscribe_get_timetoken';
		static public const LEAVE:String = 'leave';
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		protected var _origin:String = "";
		protected var _data:Object;
		protected var _connected:Boolean;
		protected var _numPresenceResponces:int
		protected var _lastChannel:String;
		
		protected var pingTimeout:int;
		protected var _connectionUID:String;
		protected var url:String;
		protected var lastToken:String;
		protected var netMonitor:NetMon;
		protected var waitNetwork:Boolean;
		protected var factory:Dictionary;
		protected var _destroyed:Boolean;
		protected var operations:/*Operation*/Array;
		protected var channels:Array;
		
		protected var connection:AsyncConnection;
		
		public function Subscribe() {
			super(null);
			init();	
		}
		
		protected function init():void {
			_numPresenceResponces = 0;
			channels = [];
			factory = new Dictionary();
			factory[GET_TIMETOKEN] = 	getOperationGetTimetoken;
			factory[WITH_TIMETOKEN] = 	getOperationWithTimetoken;
			factory[LEAVE] = 			getOperationLeave;
			
			operations = [];
			connection = new AsyncConnection();
			
			netMonitor = new NetMon();
			netMonitor.reconnectDelay = 			Settings.CONNECTION_HEARTBEAT_INTERVAL;
			netMonitor.forceReconnectDelay = 		Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			netMonitor.maxForceReconnectRetries = 	Settings.MAX_RECONNECT_RETRIES;
			netMonitor.addEventListener(NetMonEvent.HTTP_ENABLE, 	onNetMonitorHTTPEnable);
			netMonitor.addEventListener(NetMonEvent.HTTP_DISABLE, 	onNetMonitorHTTPDisable);
			netMonitor.addEventListener(NetMonEvent.MAX_RETRIES, 	onNetMonitorMaxRetries);
		}
		
		//dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:_lastChannel } ));
		/*---------------------------INIT SUBSCRIBE---------------------------*/
		protected function subscribeInit():void {
			trace('subscribeInit');
			clearTimeout(pingTimeout);
			_connectionUID = PnUtils.getUID();
			var operation:Operation = getOperation(GET_TIMETOKEN);
			connection.sendOperation(operation);	
		}
		
		protected function onConnectInit(e:OperationEvent):void {
			lastToken =  e.data[1];
			trace(this, ' onConnectInit : ' + lastToken);
			_connected = true;
			netMonitor.start();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_lastChannel } ));
			destroyOperation(e.target as Operation);
			doSubscribe();
		}
		
		protected function onConnectInitError(e:OperationEvent):void {
			_data = [ -1, Errors.SUBSCRIBE_INIT_ERROR];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------CONNECT TO SUBSCRIBE---------------------------*/
        protected function onConnect(e:OperationEvent):void {
			trace('---onConnect---');
			var responce:Object = e.data;
			lastToken = responce[1];
			var chStr:String = e.data[2];
			var multiplexResponce:Boolean = chStr && chStr.length > 0 && chStr.indexOf(',') > -1;
			var presenceResponce:Boolean = chStr.indexOf(PNPRES_PREFIX) > -1;
			
			if (presenceResponce) {
				_numPresenceResponces++;
			}
			//var needReconnect:Boolean = chStr.indexOf(PNPRES_PREFIX) > -1;
			//trace('onConnect : ' + chStr, chStr.indexOf(PNPRES_PREFIX) == -1);
			if (multiplexResponce) {
				var chArray:Array = chStr.split(',');
				for each(var i:String  in chArray) {
					parseResponce(i, responce, true);
				}
			}else {
				parseResponce(chStr, responce);
			}
            var eventData:Object = e.data;
			destroyOperation(e.target as Operation);
			
			// recoonect
			if (presenceResponce) {
				if (_numPresenceResponces == 1 && _connected) {
					doSubscribe();
				}
			}else {
				if(_connected) doSubscribe();
			}
        }
		
		private function parseResponce(channel:String, responce:Object, multiple:Boolean = false ):void {
			if (channel.indexOf(PNPRES_PREFIX) > -1) {
				// callback for Presence
				parsePresenceResponce(channel, responce, multiple);
			}else {
				//callback for a channel
				parseChannelResponce(channel, responce, multiple);
			}
		}
		
		private function parseChannelResponce(channel:String, responce:Object,  multiple:Boolean = false):void {
			if (hasChannel(channel) == false) return;
			var messages:Array = [];
			if (multiple) {
				messages.push(responce[0][0]);
			}else {
				messages = responce[0];
			}
			decryptMessages(messages);
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {channel:channel, messages : messages}));
		}
		
		private function parsePresenceResponce(channel:String, responce:Object,  multiple:Boolean = false):void {
			var parentChannel:String = channel.substr(0, channel.indexOf(PNPRES_PREFIX));
			//trace('parentChannel : ' + parentChannel);
			if (hasChannel(parentChannel) == false) return;
			var messages:Array = [];
			if (multiple) {
				messages.push(responce[0][0]);
			}else {
				messages = responce[0];
			}
			decryptMessages(messages);
			//trace('presence: ' + messages);
			dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel:channel, messages : messages}));
		}
		
		private function decryptMessages(messages:Array):void {
			 if (messages) {
                for (var i:int = 0; i < messages.length; i++) {
                    var msg:* = cipherKey.length > 0 ? PnJSON.parse(PnCrypto.decrypt(cipherKey, messages[i])) : messages[i];
					messages[i] = msg;
                }
            }
		}
		
		protected function onConnectError(e:OperationEvent):void {
			trace('onSubscribeError!');
			_data = [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data ));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------LEAVE---------------------------------*/
		protected function leave(channel:String):void {
			if (!_connected) return;
			var operation:Operation = getOperation(LEAVE, channel);
			Pn.pn_internal::syncConnection.sendOperation(operation);
		}
		
		
		protected function getOperation(type:String, ...rest):Operation {
			var op:Operation = factory[type].apply(null, rest);
			operations.push(op);
			return op;
		}
		
		protected function destroyOperation(op:Operation):void {
			op.destroy();
			var ind:int = operations.indexOf(op);
			if (ind > -1) {
				operations.splice(ind, 1);
			}
		}
		
		protected function getOperationGetTimetoken(args:Object = null):Operation {
			var operation:SubscribeInitOperation = new SubscribeInitOperation();
			operation.origin = _origin;
			operation.setURL(null, {
				channel:this.channelsString,
				subscribeKey : subscribeKey,
				uid:sessionUUID} );
			operation.addEventListener(OperationEvent.RESULT, 	onConnectInit);
			operation.addEventListener(OperationEvent.FAULT, 	onConnectInitError);
			return operation;
		}
		
		protected function getOperationWithTimetoken():Operation {
			var operation:SubscribeOperation = new SubscribeOperation();
			operation.origin = _origin;
			operation.setURL(null, {
				channel:this.channelsString,  
				timetoken: lastToken,
				subscribeKey : subscribeKey,
				channel:this.channelsString, 
				uid:sessionUUID} );
			operation.addEventListener(OperationEvent.RESULT, onConnect);
			operation.addEventListener(OperationEvent.FAULT, onConnectError);
			return operation;
		}
		
		
		protected function getOperationLeave(channel:String):Operation {
			var operation:LeaveOperation = new LeaveOperation();
			operation.origin = _origin;
			operation.setURL(null, {
				channel:channel,
				uid: sessionUUID,
				subscribeKey : subscribeKey
			});
			return operation;
		}
		
		protected function onNetMonitorMaxRetries(e:NetMonEvent):void {
			var args:Array = [Errors.RECONNECT_HEARTBEAT_TIMEOUT, lastToken];
			var op:Operation = connection ? connection.getLastOperation() : null;
			if (op) {
				args.push(op.url);
			}
			Log.log(args.join(','), Log.ERROR, Errors.RECONNECT_HEARTBEAT_TIMEOUT);
			dispose();
		}
		
		protected function onNetMonitorHTTPDisable(e:NetMonEvent):void {
			if (_connected) {
				waitNetwork = true;
				clearTimeout(pingTimeout);
			}
		}
		
		protected function onNetMonitorHTTPEnable(e:NetMonEvent):void {
			if (waitNetwork) {
				waitNetwork = false;
				if (Settings.RESUME_ON_RECONNECT) { 
					//restoreWithLastToken();
				}else {
					//restoreWithZeroToken();
				}
			}
		}
			
		public function get connected():Boolean {
			return _connected;
		}
		
		public function get lastChannel():String {
			return _lastChannel;
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
			netMonitor.origin = value;
		}
		
		public function get connectionUID():String {
			return _connectionUID;
		}
		
		public function set connectionUID(value:String):void {
			_connectionUID = value;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
		
		public function destroy():void {
			if (_destroyed) return;
			_destroyed = true;
			dispose();
			netMonitor.destroy();
			netMonitor.removeEventListener(NetMonEvent.HTTP_ENABLE, onNetMonitorHTTPEnable);
			netMonitor.removeEventListener(NetMonEvent.HTTP_DISABLE, onNetMonitorHTTPDisable);
			netMonitor = null;
			operations = null;
			_data = null;
			connection.destroy();
			connection = null;
		}
		
		protected function dispose():void {
			clearTimeout(pingTimeout);
			if (channels.length > 0) {
				leave(channels.join(','));
			}
			channels.length = 0;
			_numPresenceResponces = 0;
			waitNetwork = false;
			netMonitor.stop();
			_connected = false;
			destroyAllOperations();
			connection.close();
		}
		
		public function unsubscribeAll():void {
			var allChannels:String = channels.join(',');
			dispose();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:allChannels } ));
		}
		
		public function unsubscribe(channel:String):void {
			if (hasChannel(channel) == false) return;
			leave(channel);
			channels.splice(channels.indexOf(channel), 1);
		}
		
		public function subcribe(channel:String):void {
			if (_destroyed) return;
			var normalizedChannel:String = StringUtil.removeWhitespace(channel);
			if (hasChannel(normalizedChannel)) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.ALREADY_CONNECTED, channel]));
			}else {
				channels.push(normalizedChannel);
				_lastChannel = normalizedChannel;
				if (connected) {
					doSubscribe();
				}else {
					subscribeInit();
				}
			}
		}
		
		public function get channelsString():String {
			var result:String = '';
			var len:int = channels.length;
			var comma:String = ',';
			for (var i:int = 0; i < len; i++) {
				result += (channels[i] + comma);
				if (i == (len - 1)) {
					result += channels[i] + PNPRES_PREFIX
				}else {
					result += channels[i] + PNPRES_PREFIX + comma;
				}
			}
			return result; 
		}
		
		private function doSubscribe():void {
			trace('doSubscribe');
			var operation:Operation = getOperation(WITH_TIMETOKEN);
			connection.sendOperation(operation);
		}
		
		private function hasChannel(ch:String):Boolean{
			return (channels.indexOf(ch) > -1);
		}
		
		protected function destroyAllOperations():void {
			for each(var i:Operation  in operations) {
				i.destroy();
			}
			operations.length = 0;
		}
	}
}