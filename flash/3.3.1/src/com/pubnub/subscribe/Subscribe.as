package com.pubnub.subscribe {
	import com.pubnub.*;
	import com.pubnub.connection.*;
	import com.pubnub.environment.*;
	import com.pubnub.json.*;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	import org.casalib.util.*;
	use namespace pn_internal;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Subscribe extends EventDispatcher {
		static public const PNPRES_PREFIX:String = '-pnpres';
		
		
		static public const SUBSCRIBE:String = 'subscribe';
		static public const INIT_SUBSCRIBE:String = 'init_subscribe';
		static public const LEAVE:String = 'leave';
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		protected var _origin:String = "";
		protected var _connected:Boolean;
		//protected var _lastChannel:String;
		
		protected var _connectionUID:String;
		protected var lastToken:String;
		protected var netMonitor:NetMon;
		protected var waitNetwork:Boolean;
		protected var factory:Dictionary;
		protected var _destroyed:Boolean;
		protected var channels:Array;
		
		protected var connection:AsyncConnection;
		
		public function Subscribe() {
			super(null);
			init();	
		}
		
		protected function init():void {
			channels = [];
			factory = new Dictionary();
			factory[INIT_SUBSCRIBE] = 	getSubscribeInitOperation;
			factory[SUBSCRIBE] = 	getSubscribeOperation;
			factory[LEAVE] = 			getLeaveOperation;
			
			connection = new AsyncConnection();
			
			netMonitor = new NetMon();
			netMonitor.reconnectDelay = 			Settings.CONNECTION_HEARTBEAT_INTERVAL;
			netMonitor.forceReconnectDelay = 		Settings.RECONNECT_HEARTBEAT_TIMEOUT;
			netMonitor.maxForceReconnectRetries = 	Settings.MAX_RECONNECT_RETRIES;
			netMonitor.addEventListener(NetMonEvent.HTTP_ENABLE, 	onNetMonitorHTTPEnable);
			netMonitor.addEventListener(NetMonEvent.HTTP_DISABLE, 	onNetMonitorHTTPDisable);
			netMonitor.addEventListener(NetMonEvent.MAX_RETRIES, 	onNetMonitorMaxRetries);
		}
		
		/**
		 * Subscibe to a channel or multiple channels (use format: "ch1,ch2,ch3...")
		 * @param	channel
		 * @return	Boolean  result of subcribe (true if is subscribe to one channel or more channels)
		 */
		public function subcribe(channel:String):Boolean {
			if (isChannelCorrect(channel) == false) {
				return false;
			}
			
			// search of channels
			var addCh:Array = [];
			var temp:Array = channel.split(',');
			var ch:String;
			for (var i:int = 0; i < temp.length; i++) {
				ch = StringUtil.removeWhitespace(temp[i]);
				if (hasChannel(ch)) {
					dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.ALREADY_CONNECTED, ch]));
				}else {
					addCh.push(ch);
				}
			}
			process(addCh);
			return addCh.length > 0;
		}
		
		public function unsubscribe(channel:String):Boolean {
			if (isChannelCorrect(channel) == false) {
				return false;
			}
			// search of channels
			var removeCh:Array = [];
			var temp:Array = channel.split(',');
			var ch:String;
			for (var i:int = 0; i < temp.length; i++) {
				ch = StringUtil.removeWhitespace(temp[i]);
				if (hasChannel(ch)) {
					removeCh.push(ch);
				}else {
					dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.NOT_CONNECTED, ch]));
				}
			}
			process(null, removeCh);
			return removeCh.length > 0;
		}
		
		public function unsubscribeAll():void {
			var allChannels:String = channels.join(',');
			unsubscribe(allChannels);
			dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:allChannels } ));
		}
		
		private function process(addCh:Array = null, removeCh:Array = null):void {
			var needAdd:Boolean = addCh && addCh.length > 0;
			var needRemove:Boolean = removeCh && removeCh.length > 0;
			trace('process : ' + needAdd, needRemove);
			if (needAdd || needRemove) {
				connection.close();
				if (needRemove) {
					leave(removeCh.join(','));
					ArrayUtil.removeItems(channels, removeCh);
					
				}
				
				if (needAdd) {
					channels = channels.concat(addCh);
					//trace('after ADD channels:' + channels);
				}
				
				if (channels.length > 0) {
					if (lastToken) {
						doSubscribe();
					}else {
						subscribeInit();
					}
				}
			}
		}
		
		private function isChannelCorrect(channel:String):Boolean{
			// if destroyd it is allways false
			var result:Boolean = !_destroyed;
			// check String
			if (channel ==  null || channel.length > int.MAX_VALUE) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR, channel]));
				result = false;
			}
			return result;
		}
		
		/*---------------------------INIT---------------------------*/
		protected function subscribeInit():void {
			//trace('subscribeInit');
			_connectionUID = PnUtils.getUID();
			var operation:Operation = getOperation(INIT_SUBSCRIBE);
			connection.sendOperation(operation);	
		}
		
		protected function onSubscribeInit(e:OperationEvent):void {
			lastToken =  e.data[1];
			//trace(this, ' onConnectInit : ' + lastToken);
			_connected = true;
			netMonitor.start();
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:channels.join(',') } ));
			destroyOperation(e.target as Operation);
			doSubscribe();
		}
		
		protected function onSubscribeInitError(e:OperationEvent):void {
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_INIT_ERROR]));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------SUBSCRIBE---------------------------*/
		private function doSubscribe():void {
			var operation:Operation = getOperation(SUBSCRIBE);
			connection.sendOperation(operation);
		}
		
		protected function onConnect(e:OperationEvent):void {
			var responce:Object = e.data;
			var messages:Array = responce[0];
			lastToken = responce[1];
			var chStr:String = responce[2];
			/*
			 * MX
			 * responce = [['m1', 'm2', 'm3', 'm4'], lastToken, ['ch1', 'ch2', 'ch2', 'ch3']];
			 * 
			 * ch1 - m1
			 * ch2 - m2,m3
			 * ch3 - m4
			 * 
			 * Single channel responce
			 * responce = [['m1', 'm2', 'm3', 'm4'], lastToken];
			*/
			
			
			var multiplexResponce:Boolean = chStr && chStr.length > 0 && chStr.indexOf(',') > -1;
			var presenceResponce:Boolean = chStr.indexOf(PNPRES_PREFIX) > -1;
			var channel:String;
			
			if (presenceResponce) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel:chStr, message : messages}));
			}else {
				if (!messages) return;
				decryptMessages(messages);
				var chArray:Array = chStr.split(',');
				for (var i:int = 0; i < messages.length; i++) {
					channel = chArray[i];
					var message:* = messages[i]
					
					//trace(channel, message);
					
					if (multiplexResponce == false) {
						
						channel ||= channels[0];
					}
					if (hasChannel(channel)) {
						dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {channel:channel, message : message}));
					}
				}
			}
			doSubscribe();
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
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR] ));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------LEAVE---------------------------------*/
		protected function leave(channel:String):void {
			//trace('LEAVE : ' + channel);
			var operation:Operation = getOperation(LEAVE, channel);
			Pn.pn_internal::syncConnection.sendOperation(operation);
		}
		
		protected function getOperation(type:String, ...rest):Operation {
			return factory[type].apply(null, rest);
		}
		
		protected function destroyOperation(op:Operation):void {
			op.destroy();
		}
		
		protected function getSubscribeInitOperation(args:Object = null):Operation {
			var operation:SubscribeInitOperation = new SubscribeInitOperation();
			operation.origin = _origin;
			operation.setURL(null, {
				channel:this.channelsString,
				subscribeKey : subscribeKey,
				uid:sessionUUID} );
			operation.addEventListener(OperationEvent.RESULT, 	onSubscribeInit);
			operation.addEventListener(OperationEvent.FAULT, 	onSubscribeInitError);
			return operation;
		}
		
		protected function getSubscribeOperation():Operation {
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
		
		protected function getLeaveOperation(channel:String):Operation {
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
			/*var args:Array = [Errors.RECONNECT_HEARTBEAT_TIMEOUT, lastToken];
			var op:Operation = connection ? connection.getLastOperation() : null;
			if (op) {
				args.push(op.url);
			}
			Log.log(args.join(','), Log.ERROR, Errors.RECONNECT_HEARTBEAT_TIMEOUT);
			dispose();*/
		}
		
		protected function onNetMonitorHTTPDisable(e:NetMonEvent):void {
			if (_connected) {
				waitNetwork = true;
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
			connection.destroy();
			connection = null;
		}
		
		protected function dispose():void {
			connection.close();
			if (channels.length > 0) {
				leave(channels.join(','));
			}
			channels.length = 0;
			waitNetwork = false;
			netMonitor.stop();
			_connected = false;
		}
		
		protected function get channelsString():String {
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
		
		private function hasChannel(ch:String):Boolean{
			return (ch != null && channels.indexOf(ch) > -1);
		}
	}
}