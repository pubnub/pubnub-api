package com.pubnub.net {
	import com.adobe.net.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.net.URLRequestMethod;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class URLLoader extends EventDispatcher {
		
		public static const DEFAULT_HTTP_PORT:uint = 80;   
		public static const DEFAULT_HTTPS_PORT:uint = 443; 
		public static const HTTP_VERSION:String = "1.1";
		
		public var keepAlive:Boolean;
		private var socket:Socket;
		private var uri:URI;
		private var request:URLRequest;
		private const response:URLResponse = new URLResponse();
		private var answer:ByteArray = new ByteArray();
		private var temp:ByteArray = new ByteArray();
		private const END:String = '0\r\n';
		private var _data:Object;
		private var _connectPending:Boolean;
		private var _destroyed:Boolean;
		
		public function URLLoader() {
			super(null);
			init();
		}
		
		private function init():void {
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);       
			socket.addEventListener(Event.CLOSE, onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);  
		}
		
		private function onSocketData(e:ProgressEvent):void {
			//trace('------onSocketData------' + socket.bytesAvailable);
			temp.clear();
			while (socketHasData()) {        
				//_timer.reset();
				try {           
					// Load data from socket
					socket.readBytes(temp);
					temp.readBytes(answer, answer.bytesAvailable);
				} catch (e:Error) {
					// dispatch error
					break;
				}                           
			}
			
			temp.position = 0;
			var tempStr:String = temp.readUTFBytes(temp.bytesAvailable)
			if (tempStr.indexOf(END) != -1) {
				if (keepAlive == false) {
					close();
				}
				try {
					response.fromBytesArray(answer);
					_data = response.body;
					//trace('###onSocketResult : '  + _data);
					dispatchEvent(new Event(Event.COMPLETE));
				}catch (err:Error){
					dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, 'error parsing'));
				}
				answer.clear();	
			}
		}
		
		private function socketHasData():Boolean {
			return (socket && socket.connected && socket.bytesAvailable);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace(this, 'onSecurityError');
			//dispatchEvent(e);
		}
		
		private function onIOError(e:IOErrorEvent):void {
			trace(this, 'onIOError');
			dispatchEvent(e);
		}
		
		private function onClose(e:Event):void {
			trace('onClose');
			if (keepAlive) {
				_connectPending = true;
				socket.connect(uri.authority, DEFAULT_HTTP_PORT);
			}
			//dispatchEvent(e);
		}
		
		private function onConnect(e:Event):void {
			//trace('onConnect');
			_connectPending = false;
			sendRequest(request);
		}
		
		
		public function close():void {
			//trace('CLOSE');
			if (socket.connected) {
				socket.close();
			}
		}
		
		public function load(url:String):void {
			//trace('load : ' + url);
			_data = null;
			uri = new URI(url);
			request = new URLRequest(url);
			request.method = URLRequestMethod.GET;
			//request.header = new URLRequestHeader([ { name: "Connection", value: "Keep-Alive" } ]);
			if (socket.connected) {
				sendRequest(request);
			}else {
				if (_connectPending) return;
				socket.connect(uri.authority, DEFAULT_HTTP_PORT); 
			}
		}
		
		public function destroy():void {
			if (_destroyed) return;
			_destroyed = true;
			socket.removeEventListener(Event.CONNECT, onConnect);       
			socket.removeEventListener(Event.CLOSE, onClose);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);  
			socket.close();
			socket = null;
		}
		
		/**
		 * Send request.
		 * @param request Request to write
		 */
		protected function sendRequest(request:URLRequest):void {
			var requestBytes:ByteArray = request.toByteArray();
			requestBytes.position = 0;
			// Debug
			//var hStr:String = "Header:\n" + headerBytes.readUTFBytes(headerBytes.length);
			//trace(hStr);
			socket.writeBytes(requestBytes);      
			socket.flush();
			dispatchEvent(new Event(Event.OPEN));
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
		
		public function get connectPending():Boolean {
			return _connectPending;
		}
	}
}