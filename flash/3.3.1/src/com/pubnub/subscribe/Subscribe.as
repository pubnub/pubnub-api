package com.pubnub.subscribe {
	import com.pubnub.*;
	import com.pubnub.environment.*;
	import com.pubnub.json.*;
	import com.pubnub.json.PnJSON;
	import com.pubnub.net.Connection;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Subscribe extends EventDispatcher {
		
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
		private var lastToken:String;
		private var netMonitor:NetMon;
		private var waitNetwork:Boolean;
		private var factory:Dictionary;
		private var operations:Vector.<Operation>
		
		public function Subscribe() {
			super(null);
			init();
		}
		
		private function init():void {
			factory = new Dictionary();
			factory[Operation.GET_TIMETOKEN] = getOperationGetTimetoken;
			factory[Operation.WITH_TIMETOKEN] = getOperationWithTimetoken;
			factory[Operation.LEAVE] = getOperationLeave;
			operations = new Vector.<Operation>;
			netMonitor = new NetMon();
			netMonitor.reconnectDelay = Settings.CONNECTION_HEARTBEAT_INTERVAL;
			netMonitor.forceReconnectDelay = Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			netMonitor.maxForceReconnectRetries = Settings.MAX_RECONNECT_RETRIES;
			netMonitor.addEventListener(NetMonEvent.HTTP_ENABLE, onNetMonitorHTTPEnable);
			netMonitor.addEventListener(NetMonEvent.HTTP_DISABLE, onNetMonitorHTTPDisable);
			netMonitor.addEventListener(NetMonEvent.MAX_RETRIES, onNetMonitorMaxRetries);
		}
		
		public function subscribe(channel:String):void {
			if (_connected) {
				_data = [ -1, Errors.ALREADY_CONNECTED];
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
				return;
			}
			_channelName = channel;
			netMonitor.stop();
			subscribeInit();
		}
		
		public function unsubscribe(name:String):void {
			if (!_connected || _channelName != name) {
				return;
			}
			dispose();
			Connection.closeAsyncChannel();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:_channelName } ));
		}
		
		private function getOperation(type:String, args:Object = null):Operation {
			var op:Operation = factory[type].call(null, args);
			operations.push(op);
			return op;
		}
		
		private function destroyOperation(op:Operation):void {
			op.destroy();
			var ind:int = operations.indexOf(op);
			if (ind > -1) {
				operations.splice(ind, 1);
			}
		}
		
		private function getOperationGetTimetoken(args:Object = null):Operation {
			var operation:Operation = new Operation();
			operation.createURL({ 
				url:subscribeURL, 
				channel:_channelName, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:0, 
				operation:Operation.GET_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeInitError);
			return operation;
		}
		
		private function getOperationWithTimetoken(time:String):Operation {
			var operation:Operation = new Operation();
			operation.createURL({ 
				url:subscribeURL, 
				channel:_channelName, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:time, 
				operation:Operation.WITH_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeError);
			return operation;
		}
		
		
		private function getOperationLeave(args:Object = null):Operation {
			var operation:Operation = new Operation();
			operation.subscribeKey = subscribeKey;
			operation.channel = _channelName;
			operation.origin = _origin;
			var url:String = _origin + "/v2/presence/sub_key/" + subscribeKey + "/channel/" + PnUtils.encode(_channelName) + "/leave?uuid=" + sessionUUID;
			operation.createURL({ 
				url:url, 
				channel:_channelName, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				operation:Operation.LEAVE } );
			return operation;
		}
		
		private function onNetMonitorMaxRetries(e:NetMonEvent):void {
			unsubscribe(_channelName);
		}
		
		private function leave():void {
			if (!_connected) return;
			var operation:Operation = getOperation(Operation.LEAVE);
			Connection.sendSync(operation);
		}
		
		private function onNetMonitorHTTPDisable(e:NetMonEvent):void {
			if (_connected) {
				waitNetwork = true;
				clearTimeout(pingTimeout);
				//getOperation(Operation.WITH_TIMETOKEN).close();
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
			
		private function subscribeInit():void {
			//trace('subscribeInit');
			clearTimeout(pingTimeout);
			subscribeURL = _origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(_channelName) + "/" + 0;
			subscribeUID = PnUtils.getUID();
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			Connection.sendAsync(operation);
		}
		
		private function onSubscribeInitResult(e:OperationEvent):void {
			lastToken =  e.data[1];
			_connected = true;
			//trace('onSubscribeInitResult : ' + lastToken);
			subscribeLastToken();
			netMonitor.start();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_channelName } ));
			destroyOperation(e.target as Operation);
		}
		
		private function onSubscribeInitError(e:OperationEvent):void {
			_data = [ -1, Errors.SUBSCRIBE_INIT_ERROR];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
			destroyOperation(e.target as Operation);
		}
		
		private function subscribeToken(time:String):void {
			var operation:Operation = getOperation(Operation.WITH_TIMETOKEN, time);
			Connection.sendAsync(operation);
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
			//trace('onSubscribeResult : ' + _data.result[1].text, lastToken);
			destroyOperation(e.target as Operation);
            subscribeLastToken();
        }

        private function subscribeLastToken():void {
			//trace('subscribeLastToken : ' + lastToken);
			subscribeToken(lastToken);
			ping();
		}
		
		private function onSubscribeError(e:OperationEvent):void {
			trace('onSubscribeError');
			_data = [ -1, 'Connect channel error'];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data ));
			destroyOperation(e.target as Operation);
		}
		
		private function restoreWithLastToken():void {
			subscribeToken(lastToken);
		}
		
		private function restoreWithZeroToken():void {
			lastToken = '0';
			subscribeToken(lastToken);
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
			netMonitor.removeEventListener(NetMonEvent.HTTP_ENABLE, onNetMonitorHTTPEnable);
			netMonitor.removeEventListener(NetMonEvent.HTTP_DISABLE, onNetMonitorHTTPDisable);
			netMonitor = null;
			operations = null;
			_data = null;
		}
		
		public function dispose():void {
			clearTimeout(pingTimeout);
			waitNetwork = false;
			netMonitor.stop();
			leave();
			_connected = false;
			Connection.removeSyncOperations(operations);
			destroyAllOperations();
		}
		
		private function destroyAllOperations():void {
			for each(var i:Operation  in operations) {
				i.destroy();
			}
			operations.length = 0;
		}
	}
}