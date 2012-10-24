package com.pubnub.subscribe {
	import com.pubnub.*;
	import com.pubnub.environment.*;
	import com.pubnub.json.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Subscribe extends EventDispatcher {
		private static const WAIT_NETWORK_DELAY:Number = 1500000; // 1500 seconds
		
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		private var _origin:String = "";
		private var _data:Object;
		private var pingTimeout:int;
		private var subscribeUID:String;
		private var subscribeURL:String;
		private var _connected:Boolean;
		private var _name:String;
		private var operations:Dictionary;
		private var lastToken:String;
		private var netMonitor:NetMon;
		private var waitNetwork:Boolean;
		private var waitNetworkTimeout:int;
		
		public function Subscribe() {
			super(null);
			init();
		}
		
		private function init():void {
			operations = new Dictionary();
			netMonitor = new NetMon();
			netMonitor.addEventListener(NetMonEvent.HTTP_ENABLE, onNetMonitorHTTPEnable);
			netMonitor.addEventListener(NetMonEvent.HTTP_DISABLE, onNetMonitorHTTPDisable);
		}
		
		private function onNetMonitorHTTPDisable(e:NetMonEvent):void {
			if (_connected) {
				waitNetwork = true;
				clearTimeout(waitNetworkTimeout);
				waitNetworkTimeout = setTimeout(unsubscribe, WAIT_NETWORK_DELAY, _name);
				getOperation(Operation.WITH_TIMETOKEN).close();
			}
		}
		
		private function onNetMonitorHTTPEnable(e:NetMonEvent):void {
			if (waitNetwork) {
				waitNetwork = false;
				clearTimeout(waitNetworkTimeout);
				restoreSubscribe();
			}
		}
		
		public function subscribe(channel:String):void {
			if (_connected) {
				_data = [ -1, 'Already Connected'];
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
				return;
			}
			_name = channel;
			netMonitor.stop();
			subscribeInit();
		}
		
		private function subscribeInit():void {
			//trace('subscribeInit');
			clearTimeout(pingTimeout);
			getOperation(Operation.WITH_TIMETOKEN).close();
			getOperation(Operation.GET_TIMETOKEN).close();
			subscribeURL = _origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(_name) + "/" + 0;
			subscribeUID = PnUtils.getUID();
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			operation.send({ 
				url:subscribeURL, 
				channel:_name, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:0, 
				operation:Operation.GET_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeInitError);
		}
		
		private function onSubscribeInitResult(e:OperationEvent):void {
			//trace('onSubscribeInitResult: ' + e.data[1]);
			lastToken =  e.data[1];
			_connected = true;
			subscribeToken(lastToken);
			ping();
			netMonitor.start();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_name } ));
		}
		
		private function onSubscribeInitError(e:OperationEvent):void {
			_data = [ -1, 'Init channel error'];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
		}
		
		private function subscribeToken(time:String):void {
			//trace('subscribeWithToken : ' + time);
			var operation:Operation = getOperation(Operation.WITH_TIMETOKEN);
			operation.send({ 
				url:subscribeURL, 
				channel:_name, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:time, 
				operation:Operation.WITH_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeError);
		}
		
		private function onSubscribeResult(e:OperationEvent):void {
			var result:Object = e.data;  
			lastToken = result[1];	
			var messages:Array = result[0]; 
			//trace('onSubscribeResult : ' + lastToken);
			if(messages) {
				for (var i:int = 0; i < messages.length; i++) {
					if(cipherKey.length > 0){
						_data = { 
							channel:_name, 
							result:[i+1,PnCrypto.decrypt(cipherKey,messages[i])], 
							envelope: result, 
							timeout:1 
						}
						dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA,  _data));
					}
					else {
						_data = { 
							channel:_name, 
							result:[i+1,PnJSON.stringify(messages[i])], 
							envelope: result, 
							timeout:1 
						} 
						dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, _data));
					}	
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
			if (!_connected || _name != name) {
				return;
			}
			dispose();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:_name } ));
		}
		
		private function restoreSubscribe():void {
			clearTimeout(pingTimeout);
			getOperation(Operation.WITH_TIMETOKEN).close();
			getOperation(Operation.GET_TIMETOKEN).close();
			subscribeURL = _origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(_name) + "/" + 0;
			//trace('restoreSubscribe : ' + subscribeURL);
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			operation.send({ 
				url:subscribeURL, 
				channel:_name, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:0, 
				operation:Operation.GET_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeInitError);
		}
		
		private function getOperation(type:String):Operation {
			var result:Operation = operations[type] || new Operation();
			operations[type] = result;
			return result;
		}
		
		
		
		private function ping():void {
			clearTimeout(pingTimeout);
			pingTimeout = setTimeout(subscribeLastToken, Operation.TIMEOUT);
		}
		
		
		
		public function get connected():Boolean {
			return _connected;
		}
		
		public function get name():String {
			return _name;
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
			
			operations = null;
			_data = null;
		}
		
		public function dispose():void {
			clearTimeout(pingTimeout);
			clearTimeout(waitNetworkTimeout);
			_connected = false;
			waitNetwork = false;
			netMonitor.stop();
			getOperation(Operation.GET_TIMETOKEN).close();
			getOperation(Operation.WITH_TIMETOKEN).close();
		}
	}
}