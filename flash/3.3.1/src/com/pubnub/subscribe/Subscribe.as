package com.pubnub.subscribe {
	import com.pubnub.*;
	import com.pubnub.environment.*;
	import com.pubnub.json.*;
import com.pubnub.json.PnJSON;
import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Subscribe extends EventDispatcher {
		//public static const RESUME_ON_RECONNECT:Boolean = true;
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		private var _origin:String = "";
		private var _data:Object;
		private var _connected:Boolean;
		private var _channelName:String;
		
		private var pingTimeout:int;
		private var subscribeUID:String;
		private var subscribeURL:String;
		private var operations:Dictionary;
		private var lastToken:String;
		private var netMonitor:NetMon;
		private var waitNetwork:Boolean;
		
		public function Subscribe() {
			super(null);
			init();
		}
		
		private function init():void {
			operations = new Dictionary();
			netMonitor = new NetMon();
			netMonitor.reconnectDelay = Settings.CONNECTION_HEARTBEAT_INTERVAL;
			netMonitor.forceReconnectDelay = Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			netMonitor.maxForceReconnectRetries = Settings.MAX_RECONNECT_RETRIES;
			netMonitor.addEventListener(NetMonEvent.HTTP_ENABLE, onNetMonitorHTTPEnable);
			netMonitor.addEventListener(NetMonEvent.HTTP_DISABLE, onNetMonitorHTTPDisable);
			netMonitor.addEventListener(NetMonEvent.MAX_RETRIES, onNetMonitorMaxRetries);
		}
		
		private function onNetMonitorMaxRetries(e:NetMonEvent):void {
			unsubscribe(_channelName);
		}
		
		private function leave():void {
			if (!_connected) return;
			var operation:Operation = getOperation(Operation.LEAVE);
			operation.subscribeKey = subscribeKey;
			operation.channel = _channelName;
			operation.origin = _origin;
			var url:String = _origin + "/v2/presence/sub_key/" + subscribeKey + "/channel/" + PnUtils.encode(_channelName) + "/leave?uuid=" + sessionUUID;
			operation.send({ 
				url:url, 
				channel:_channelName, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				operation:Operation.LEAVE } );
		}
		
		private function onNetMonitorHTTPDisable(e:NetMonEvent):void {
			if (_connected) {
				waitNetwork = true;
				clearTimeout(pingTimeout);
				getOperation(Operation.WITH_TIMETOKEN).close();
			}
		}
		
		private function onNetMonitorHTTPEnable(e:NetMonEvent):void {
			if (waitNetwork) {
				waitNetwork = false;
				if (Settings.RESUME_ON_RECONNECT) { 
					restoreWithLastToken();
				}else {
					restoreWithZeroToken();
				}
			}
		}
			
		public function subscribe(channel:String):void {
			if (_connected) {
				_data = [ -1, 'Already Connected'];
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
				return;
			}
			_channelName = channel;
			netMonitor.stop();
			subscribeInit();
		}
		
		private function subscribeInit():void {
			//trace('subscribeInit');
			clearTimeout(pingTimeout);
			getOperation(Operation.WITH_TIMETOKEN).close();
			getOperation(Operation.GET_TIMETOKEN).close();
			subscribeURL = _origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(_channelName) + "/" + 0;
			subscribeUID = PnUtils.getUID();
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			operation.send({ 
				url:subscribeURL, 
				channel:_channelName, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:0, 
				operation:Operation.GET_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeInitError);
		}
		
		private function onSubscribeInitResult(e:OperationEvent):void {
			lastToken =  e.data[1];
			_connected = true;
			subscribeToken(lastToken);
			ping();
			netMonitor.start();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_channelName } ));
		}
		
		private function onSubscribeInitError(e:OperationEvent):void {
			_data = [ -1, 'Init channel error'];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
		}
		
		private function subscribeToken(time:String):void {
			var operation:Operation = getOperation(Operation.WITH_TIMETOKEN);
			operation.send({ 
				url:subscribeURL, 
				channel:_channelName, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:time, 
				operation:Operation.WITH_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeError);
		}

        private function onSubscribeResult(e:OperationEvent):void {
            var eventData:Object = e.data;
            lastToken = eventData[1];
            var messages:Array = eventData[0];
            if (messages) {

                for (var i:int = 0; i < messages.length; i++) {

                    var msg:* = cipherKey.length > 0 ? PnJSON.parse(PnCrypto.decrypt(cipherKey, messages[i])) : messages[i];

                    _data = {
                        channel:_channelName,
                        result:[i + 1, msg],
                        //envelope:eventData,
                        timeout:1
                    }

                    dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, _data));
                }
            }
            subscribeLastToken();
        }

        private function subscribeLastToken():void {
			//trace('subscribeLastToken : ' + lastToken);
			getOperation(Operation.WITH_TIMETOKEN).close();
			subscribeToken(lastToken);
			ping();
		}
		
		private function onSubscribeError(e:OperationEvent):void {
			_data = [ -1, 'Connect channel error'];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data ));
		}
		
		public function unsubscribe(name:String):void {
			if (!_connected || _channelName != name) {
				return;
			}
			dispose();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:_channelName } ));
		}
		
		private function restoreWithLastToken():void {
			subscribeToken(lastToken);
		}
		
		private function restoreWithZeroToken():void {
			lastToken = '0';
			subscribeToken(lastToken);
		}
		
		private function getOperation(type:String):Operation {
			var result:Operation = operations[type] || new Operation();
			operations[type] = result;
			return result;
		}
		
		private function ping():void {
			clearTimeout(pingTimeout);
			pingTimeout = setTimeout(subscribeLastToken, Settings.OPERATION_TIMEOUT);
		}
		
		public function get connected():Boolean {
			return _connected;
		}
		
		public function get channelName():String {
			return _channelName;
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
		
		public function destroy():void {
			dispose();
			
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			operation.removeEventListener(OperationEvent.RESULT, onSubscribeResult);
			operation.removeEventListener(OperationEvent.FAULT, onSubscribeError);
			
			operation = getOperation(Operation.WITH_TIMETOKEN);
			operation.removeEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.removeEventListener(OperationEvent.FAULT, onSubscribeInitError);
			
			netMonitor.removeEventListener(NetMonEvent.HTTP_ENABLE, onNetMonitorHTTPEnable);
			netMonitor.removeEventListener(NetMonEvent.HTTP_DISABLE, onNetMonitorHTTPDisable);
			netMonitor = null;
			
			getOperation(Operation.LEAVE).close();
			
			operations = null;
			_data = null;
		}
		
		public function dispose():void {
			clearTimeout(pingTimeout);
			waitNetwork = false;
			netMonitor.stop();
			getOperation(Operation.GET_TIMETOKEN).close();
			getOperation(Operation.WITH_TIMETOKEN).close();
			leave();
			_connected = false;
		}
	}
}