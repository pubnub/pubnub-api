package com.pubnub.channel {
	import com.pubnub.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Channel extends EventDispatcher {
		
		public var origin:String = "";
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		private var _data:Object;
		
		private var subscribeUID:String;
		private var subscribeURL:String;
		private var _connected:Boolean;
		private var _name:String;
		private var operations:Dictionary;
		
		
		public function Channel() {
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
				dispatchEvent(new ChannelEvent(ChannelEvent.ERROR, _data));
				return;
			}
			this._name = channel;
			var time:Number = 0;
			
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
			dispatchEvent(new ChannelEvent(ChannelEvent.ERROR, _data));
			
		}
		
		private function onSubscribeInitResult(e:OperationEvent):void {
			var time:Number =  e.data[1];
			_connected = true;
			dispatchEvent(new ChannelEvent(ChannelEvent.CONNECT,  { channel:_name } ));
			subscribeWithTimeToken(time);
		}
		
		private function subscribeWithTimeToken(time:Number):void {
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
			dispatchEvent(new ChannelEvent(ChannelEvent.ERROR, _data ));
		}
		
		private function onSubscribeResult(e:OperationEvent):void {
			var result:Object = e.data;  
			var time:Number = result[1];	
			trace(time);
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
						dispatchEvent(new ChannelEvent(ChannelEvent.DATA,  _data));
					}
					else {
						_data = { 
							channel:_name, 
							result:[i+1,JSON.stringify(messages[i])], 
							envelope: result, 
							timeout:1 
						} 
						dispatchEvent(new ChannelEvent(ChannelEvent.DATA, _data));
						
					}	
				}
			}
			subscribeWithTimeToken(time);
		}
		
		public function unsubscribe(name:String):void {
			if (!_connected || this._name != name) {
				return;
			}
			getOperation(Operation.GET_TIMETOKEN).close();
			getOperation(Operation.WITH_TIMETOKEN).close();
			_connected = false;
			dispatchEvent(new ChannelEvent(ChannelEvent.DISCONNECT, { channel:_name } ));
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
			getOperation(Operation.GET_TIMETOKEN).close();
			getOperation(Operation.WITH_TIMETOKEN).close();
		}
	}
}