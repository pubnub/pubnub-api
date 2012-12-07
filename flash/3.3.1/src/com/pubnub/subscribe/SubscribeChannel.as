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
	use namespace pn_internal;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	[Event(name="ChannelEvent.error", type="com.pubnub.subscribe.SubscribeEvent")]
	public class SubscribeChannel extends EventDispatcher {
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		protected var _origin:String = "";
		protected var _data:Object;
		protected var _connected:Boolean;
		protected var _channelName:String;
		
		protected var pingTimeout:int;
		protected var _connectionUID:String;
		protected var url:String;
		protected var lastToken:String;
		protected var netMonitor:NetMon;
		protected var waitNetwork:Boolean;
		protected var factory:Dictionary;
		protected var _destroyed:Boolean;
		protected var operations:/*Operation*/Array;
		
		protected var connection:Connection;
		
		public function SubscribeChannel() {
			super(null);
			init();	
		}
		
		protected function init():void {
			factory = new Dictionary();
			factory[Operation.GET_TIMETOKEN] = 	getOperationGetTimetoken;
			factory[Operation.WITH_TIMETOKEN] = getOperationWithTimetoken;
			factory[Operation.LEAVE] = 			getOperationLeave;
			
			operations = [];
			connection = new AsyncConnection();
			
			netMonitor = new NetMon();
			netMonitor.reconnectDelay = Settings.CONNECTION_HEARTBEAT_INTERVAL;
			netMonitor.forceReconnectDelay = Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			netMonitor.maxForceReconnectRetries = Settings.MAX_RECONNECT_RETRIES;
			netMonitor.addEventListener(NetMonEvent.HTTP_ENABLE, 	onNetMonitorHTTPEnable);
			netMonitor.addEventListener(NetMonEvent.HTTP_DISABLE, 	onNetMonitorHTTPDisable);
			netMonitor.addEventListener(NetMonEvent.MAX_RETRIES, 	onNetMonitorMaxRetries);
		}
		
		public function connect(channel:String):void {
			trace(this, ' connect:' +channel, _connected);
			if (_connected) {
				_data = [ -1, Errors.ALREADY_CONNECTED];
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
				return;
			}
			_channelName = channel;
			netMonitor.stop();
			connectInit();
		}
		
		public function disconnect():void {
			if (!_connected) {
				return;
			}
			dispose();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:_channelName } ));
		}
		
		
		/*---------------------------INIT SUBSCRIBE---------------------------*/
		protected function connectInit():void {
			
			clearTimeout(pingTimeout);
			url = _origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(_channelName) + "/" + 0;
			_connectionUID = PnUtils.getUID();
			//trace(this, ' connectInit : ' + url);
			var operation:Operation = getOperation(Operation.GET_TIMETOKEN);
			connection.sendOperation(operation);	
		}
		
		protected function onConnectInit(e:OperationEvent):void {
			lastToken =  e.data[1];
			//trace(this, ' onConnectInit : ' + lastToken, hasEventListener(SubscribeEvent.CONNECT));
			_connected = true;
			connectLastToken();
			netMonitor.start();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_channelName } ));
			destroyOperation(e.target as Operation);
		}
		
		protected function onConnectInitError(e:OperationEvent):void {
			_data = [ -1, Errors.SUBSCRIBE_INIT_ERROR];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------CONNECT TO SUBSCRIBE---------------------------*/
		protected function connectToken(time:String):void {
			var operation:Operation = getOperation(Operation.WITH_TIMETOKEN, time);
			connection.sendOperation(operation);
		}

        protected function onConnect(e:OperationEvent):void {
            var eventData:Object = e.data;
            lastToken = eventData[1];
            var messages:Array = eventData[0];
            if (messages) {
                for (var i:int = 0; i < messages.length; i++) {
                    var msg:* = cipherKey.length > 0 ? PnJSON.parse(PnCrypto.decrypt(cipherKey, messages[i])) : messages[i];
                    _data = {
                        channel:_channelName,
                        result:[i + 1, msg],
                        timeout:1
                    }
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, _data));
                }
            }
			//trace('onConnect : ' + _data.result[1].text, lastToken);
			destroyOperation(e.target as Operation);
            connectLastToken();
        }

        protected function connectLastToken():void {
			//trace('subscribeLastToken : ' + lastToken);
			connectToken(lastToken);
			ping();
		}
		
		protected function onConnectError(e:OperationEvent):void {
			trace('onSubscribeError!');
			_data = [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR];
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, _data ));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------LEAVE---------------------------------*/
		protected function leave():void {
			if (!_connected) return;
			trace(this, 'leave : ' + _connected);
			var operation:Operation = getOperation(Operation.LEAVE);
			Pn.pn_internal::syncConnection.sendOperation(operation);
		}
		
		
		protected function getOperation(type:String, args:Object = null):Operation {
			var op:Operation = factory[type].call(null, args);
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
			var operation:Operation = new Operation();
			operation.createURL({ 
				url:url, 
				channel:_channelName, 
				uid:_connectionUID, 
				sessionUUID : sessionUUID,
				timetoken:0, 
				operation:Operation.GET_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, 	onConnectInit);
			operation.addEventListener(OperationEvent.FAULT, 	onConnectInitError);
			return operation;
		}
		
		protected function getOperationWithTimetoken(time:String):Operation {
			var operation:Operation = new Operation();
			operation.createURL({ 
				url:url, 
				channel:_channelName, 
				uid:_connectionUID, 
				sessionUUID : sessionUUID,
				timetoken:time, 
				operation:Operation.WITH_TIMETOKEN } );
			operation.addEventListener(OperationEvent.RESULT, onConnect);
			operation.addEventListener(OperationEvent.FAULT, onConnectError);
			return operation;
		}
		
		
		protected function getOperationLeave(args:Object = null):Operation {
			var operation:Operation = new Operation();
			operation.subscribeKey = subscribeKey;
			operation.channel = _channelName;
			operation.origin = _origin;
			var url:String = _origin + "/v2/presence/sub_key/" + subscribeKey + "/channel/" + PnUtils.encode(_channelName) + "/leave?uuid=" + sessionUUID;
			operation.createURL({ 
				url:url, 
				channel:_channelName, 
				uid:_connectionUID, 
				sessionUUID : sessionUUID,
				operation:Operation.LEAVE } );
			
			return operation;
		}
		
		protected function onNetMonitorMaxRetries(e:NetMonEvent):void {
			var args:Array = [Errors.RECONNECT_HEARTBEAT_TIMEOUT, lastToken];
			var op:Operation = connection ? connection.getLastOperation() : null;
			if (op) {
				args.push(op.url);
			}
			Log.log(args.join(','), Log.ERROR, Errors.RECONNECT_HEARTBEAT_TIMEOUT);
			disconnect();
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
					restoreWithLastToken();
				}else {
					restoreWithZeroToken();
				}
			}
		}
			
		protected function restoreWithLastToken():void {
			connectToken(lastToken);
		}
		
		protected function restoreWithZeroToken():void {
			lastToken = '0';
			connectToken(lastToken);
		}
		
		protected function ping():void {
			clearTimeout(pingTimeout);
			pingTimeout = setTimeout(connectLastToken, Settings.OPERATION_TIMEOUT);
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
		
		public function dispose():void {
			clearTimeout(pingTimeout);
			if (connected) {
				leave();
			}
			waitNetwork = false;
			netMonitor.stop();
			_connected = false;
			connection.close();
			destroyAllOperations();
		}
		
		protected function destroyAllOperations():void {
			for each(var i:Operation  in operations) {
				i.destroy();
			}
			operations.length = 0;
		}
	}
}