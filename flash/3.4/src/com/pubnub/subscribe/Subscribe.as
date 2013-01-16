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
		
		static public const PNPRES_PREFIX:String = 	'-pnpres';
		static public const SUBSCRIBE:String = 		'subscribe';
		static public const INIT_SUBSCRIBE:String = 'init_subscribe';
		static public const LEAVE:String = 			'leave';
		
		public var subscribeKey:String;
		public var sessionUUID:String;
		public var cipherKey:String;
		
		protected var _origin:String = "";
		protected var _connected:Boolean;
		
		protected var _connectionUID:String;
		protected var _lastToken:String;
		protected var _reusedToken:String
		protected var factory:Dictionary;
		protected var _destroyed:Boolean;
		protected var _channels:Array;
		protected var savedChannels:Array;
		protected var savedTimetoken:String
		
		protected var connection:AsyncConnection;
		protected var _networkEnabled:Boolean;
		
		
		public function Subscribe() {
			super(null);
			init();	
		}
		
		protected function init():void {
			_channels = [];
			factory = new Dictionary();
			factory[INIT_SUBSCRIBE] = 	getSubscribeInitOperation;
			factory[SUBSCRIBE] = 		getSubscribeOperation;
			factory[LEAVE] = 			getLeaveOperation;
			
			connection = new AsyncConnection();
			connection.addEventListener(OperationEvent.TIMEOUT, onTimeout);
		}
		
		private function onTimeout(e:OperationEvent):void {
			var operation:Operation = e.data as Operation;
			if (_networkEnabled) {
				var tkn:String = Settings.RESUME_ON_RECONNECT ? _lastToken : '0';
				var chs:Array = _channels.concat();
				close('Reconnecting due to client-side timeout');
				if (chs && chs.length > 0) {
					subcribe(chs.join(','), tkn);
				}
			}
		}
		
		/**
		 * Subscibe to a channel or multiple channels (use format: "ch1,ch2,ch3...")
		 * @param	channel
		 * @return	Boolean  result of subcribe (true if is subscribe to one channel or more channels)
		 */
		public function subcribe(channel:String, token:String = null):Boolean {
			if (!checkNetwork()) return false;
			
			if (!checkChannelName(channel)) return false;
			
			if (token) {
				_reusedToken = token;
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
		
		private function checkChannelName(channel:String):Boolean {
			var result:Boolean = isChannelCorrect(channel)
			if (result == false) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR, channel]));
				return false;
			}
			return result;
		}
		
		private function checkNetwork():Boolean {
			if (_networkEnabled == false) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.NETWORK_UNAVAILABLE]));
				return false;
			}
			return _networkEnabled;
		}
		
		public function unsubscribe(channel:String, reason:Object = null):Boolean {
			if (!checkNetwork()) return false;
			
			if (!checkChannelName(channel)) return false;
			
			return doUnsubscribe(channel, reason);
		}
		
		private function doUnsubscribe(channel:String, reason:Object = null):Boolean {
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
			process(null, removeCh, reason);
			return removeCh.length > 0;
		}
		
		public function unsubscribeAll(reason:Object = null):void {
			if (!checkNetwork()) return;
			doUnsubscribeAll(reason);
		}
		
		private function doUnsubscribeAll(reason:Object = null):void {
			//clearInterval(resubTimer);
			var allChannels:String = _channels.join(',');
			unsubscribe(allChannels, reason);
		}
		
		private function process(addCh:Array = null, removeCh:Array = null, reason:Object = null):void {
			var needAdd:Boolean = addCh && addCh.length > 0;
			var needRemove:Boolean = removeCh && removeCh.length > 0;
			if (needAdd || needRemove) {
				connection.close();
				if (needRemove) {
					var removeChStr:String = removeCh.join(',');
					leave(removeChStr);
					ArrayUtil.removeItems(_channels, removeCh);
					dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel:removeChStr, reason : (reason ? reason : '') } ));	
				}
				
				if (needAdd) {
					_channels = _channels.concat(addCh);
				}
				
				//trace('_lastToken : ' + _lastToken);
				if (_channels.length > 0) {
					if (_lastToken) {
						doSubscribe();
					}else {
						subscribeInit();
					}
				}else {
					_lastToken = null;
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
			//trace('subscribeInit : ' + sessionUUID, _channels);
			_connectionUID = PnUtils.getUID();
			var operation:Operation = getOperation(INIT_SUBSCRIBE);
			connection.sendOperation(operation);	
		}
		
		protected function onSubscribeInit(e:OperationEvent):void {
			if (_networkEnabled == false) return;
			
			if (e.data == null) {
				subscribeInit();
				return;
			}
			_connected = true;
			_lastToken = e.data[1];
			//trace('onSubscribeInit : ' + _lastToken);
			if (_reusedToken) {
				_lastToken = _reusedToken;
				_reusedToken = null;
			}
			
			
			dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT,  { channel:_channels.join(',') } ));
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
			
			if (_networkEnabled == false) return;
			
			var responce:Object = e.data;
			
			// something is wrong
			if (responce == null) {
				doSubscribe();
				return;
			}
			
			var messages:Array = responce[0] as Array;
			
			_lastToken = responce[1];
			var chStr:String = responce[2];
			
			/*
			 * MX (array.length = 3)
			 * responce = [['m1', 'm2', 'm3', 'm4'], lastToken, ['ch1', 'ch2', 'ch2', 'ch3']];
			 * 
			 * ch1 - m1
			 * ch2 - m2,m3
			 * ch3 - m4
			 * 
			 * Single channel responce (array.length = 2)
			 * responce = [['m1', 'm2', 'm3', 'm4'], lastToken];
			*/
			
			var multiplexResponce:Boolean = chStr && chStr.length > 0 && chStr.indexOf(',') > -1;
			var presenceResponce:Boolean = chStr && chStr.indexOf(PNPRES_PREFIX) > -1;
			var channel:String;
			
			if (presenceResponce) {
				dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel:chStr, message : messages}));
			}else {
				if (!messages) return;
				decryptMessages(messages);
				var message:String;
				if (multiplexResponce) {
					var chArray:Array = chStr.split(',');
					for (var i:int = 0; i < messages.length; i++) {
						channel = chArray[i];
						message = messages[i];
						if (hasChannel(channel)) {
							dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
								channel:channel, 
								message : message}));
						}
					}
				}else {
					channel = chStr || _channels[0];
					for (var j:int = 0; j < messages.length; j++) {
						message = messages[j];
						var isValidMessage:Boolean = message && message.length > 0;
						if (isValidMessage) {
							dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
								channel:channel, 
								message : messages[j]}));
						}
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
			//trace('onSubscribeError!');
			dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR] ));
			destroyOperation(e.target as Operation);
		}
		
		/*---------------------------LEAVE---------------------------------*/
		protected function leave(channel:String):void {
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
			var operation:SubscribeInitOperation = new SubscribeInitOperation(origin);
			operation.setURL(null, {
				channel:this.channelsString,
				subscribeKey : subscribeKey,
				uid:sessionUUID} );
			operation.addEventListener(OperationEvent.RESULT, 	onSubscribeInit);
			operation.addEventListener(OperationEvent.FAULT, 	onSubscribeInitError);
			return operation;
		}
		
		protected function getSubscribeOperation():Operation {
			var operation:SubscribeOperation = new SubscribeOperation(origin);
			operation.setURL(null, {
				timetoken: _lastToken,
				subscribeKey : subscribeKey,
				channel:this.channelsString, 
				uid:sessionUUID} );
			operation.addEventListener(OperationEvent.RESULT, onConnect);
			operation.addEventListener(OperationEvent.FAULT, onConnectError);
			return operation;
		}
		
		protected function getLeaveOperation(channel:String):Operation {
			var operation:LeaveOperation = new LeaveOperation(origin);
			operation.setURL(null, {
				channel:channel,
				uid: sessionUUID,
				subscribeKey : subscribeKey
			});
			return operation;
		}
			
		public function get connected():Boolean {
			return _connected;
		}
		
		public function get origin():String {
			return _origin;
		}
		
		public function set origin(value:String):void {
			_origin = value;
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
			close();
			connection.removeEventListener(OperationEvent.TIMEOUT, onTimeout);
			connection.destroy();
			connection = null;
		}
		
		public function close(reason:String = null):void {
			doUnsubscribeAll(reason);
			connection.close();
			if (_channels.length > 0) {
				leave(_channels.join(','));
			}
			_channels.length = 0;
			_connected = false;
			_lastToken = null;
		}
		
		protected function get channelsString():String {
			var result:String = '';
			var len:int = _channels.length;
			var comma:String = ',';
			for (var i:int = 0; i < len; i++) {
                if (i == (len - 1)) {
					result += _channels[i]
				}else {
					result += _channels[i] + comma;
                }
			}
			return result; 
		}
		
		public function get channels():Array {
			return _channels;
		}
		
		public function set networkEnabled(value:Boolean):void {
			_networkEnabled = value;
			connection.networkEnabled = value;
			if (value) {
				
				if (Settings.RESUME_ON_RECONNECT) {
					var token:String = savedTimetoken;	
				}
				if (savedChannels && savedChannels.length > 0) {
					subcribe(savedChannels.join(','), token);
				}
				savedTimetoken = null;
				savedChannels = [];
			}else {
				savedTimetoken = _lastToken;
				savedChannels = _channels.concat();
				close('Close with network unavailable');
			}
		}
		
		public function get networkEnabled():Boolean {
			return _networkEnabled;
		}
		
		public function get lastToken():String {
			return _lastToken;
		}
		
		private function hasChannel(ch:String):Boolean{
			return (ch != null && _channels.indexOf(ch) > -1);
		}
	}
}