package com.pubnub.subscribe {
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Subscribe extends EventDispatcher {
		
		public static const PING_TIMEOUT_VALUE:Number = 120000;
		
		public var origin:String = "";
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		private var _data:Object;
		
		private var pingTimeout:int;
		private var subscribeUID:String;
		private var subscribeURL:String;
		private var _connected:Boolean;
		private var _name:String;
		private var operations:Dictionary;
		private var lastToken:String
		
		
		public function Subscribe() {
			super(null);
			init();
		}
		
		private function init():void {
			operations = new Dictionary();
		}
		
		private function getOperation(type:String):Operation {
			var result:Operation = operations[type] || new Operation();
			operations[type] = result;
			return result;
		}
		
		public function subscribe(channel:String):void {
			if (_connected) {
				_data = [ -1, 'Already Connected'];
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
				return;
			}
			this._name = channel;
			var time:Number = 0;
			clearTimeout(pingTimeout);
			subscribeURL = origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(channel) + "/" + 0;
			subscribeUID = PnUtils.getUID();
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			operation.send({ 
				url:subscribeURL, 
				channel:channel, 
				uid:subscribeUID, 
				sessionUUID : sessionUUID,
				timetoken:time, 
				operation:Operation.GET_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.addEventListener(OperationEvent.FAULT, onSubscribeInitError);
			
		}
		
		private function onSubscribeInitError(e:OperationEvent):void {
			_data = [ -1, 'Init channel error'];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
			
		}
		
		private function onSubscribeInitResult(e:OperationEvent):void {
			lastToken =  e.data[1];
			_connected = true;
			//clearTimeout(pingTimeout);
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_name } ));
			subscribeWithTimeToken(lastToken);
		}
		
		private function subscribeWithTimeToken(time:String):void {
			//trace('subscribeWithToken : ' + time);
			//getOperation(Operation.WITH_TIMETOKEN).close();
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
		
		private function onSubscribeError(e:OperationEvent):void {
			_data = [ -1, 'Connect channel error'];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data ));
			ping();
		}
		
		private function onSubscribeResult(e:OperationEvent):void {
			//trace('onSubscribeResult : ' + pingTimeout);
			var result:Object = e.data;  
			lastToken = result[1];	
			var messages:Array = result[0];    
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
			ping();
		}
		
		private function ping():void {
			subscribeWithTimeToken(lastToken);
			clearTimeout(pingTimeout);
			pingTimeout = setTimeout(subscribeWithLastToken, PING_TIMEOUT_VALUE);
		}
		
		private function subscribeWithLastToken():void {
			subscribeWithTimeToken(lastToken);
		}
		
		public function unsubscribe(name:String):void {
			if (!_connected || this._name != name) {
				return;
			}
			 dispose()
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:_name } ));
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
		
		public function destroy():void {
			dispose();
			
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			operation.removeEventListener(OperationEvent.RESULT, onSubscribeResult);
			operation.removeEventListener(OperationEvent.FAULT, onSubscribeError);
			
			operation = getOperation(Operation.WITH_TIMETOKEN);
			operation.removeEventListener(OperationEvent.RESULT, onSubscribeInitResult);
			operation.removeEventListener(OperationEvent.FAULT, onSubscribeInitError);
			
			operation = null;
		}
		
		public function dispose():void {
			_connected = false;
			clearTimeout(pingTimeout);
			getOperation(Operation.GET_TIMETOKEN).close();
			getOperation(Operation.WITH_TIMETOKEN).close();
		}
	}
}