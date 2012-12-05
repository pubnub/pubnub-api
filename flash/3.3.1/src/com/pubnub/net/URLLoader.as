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
	[Event(name="URLLoaderEvent.complete", type="com.pubnub.net.URLLoaderEvent")]
	[Event(name="URLLoaderEvent.error", type="com.pubnub.net.URLLoaderEvent")]
	public class URLLoader extends EventDispatcher {
		
		public static const DEFAULT_HTTP_PORT:uint = 80;   
		public static const DEFAULT_HTTPS_PORT:uint = 443; 
		public static const HTTP_VERSION:String = "1.1";
		
		public static const END_SYMBOL_CHUNKED:String = '0\r\n';
		public static const END_SYMBOL:String = '\r\n';
		
		protected var socket:Socket;
		protected var uri:URI;
		protected var request:URLRequest;
		protected var _response:URLResponse;
		protected var answer:ByteArray = new ByteArray();
		protected var temp:ByteArray = new ByteArray();
		
		protected var _destroyed:Boolean;
		
		public function URLLoader() {
			super(null);
			init();
		}
		
		protected function init():void {
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);       
			socket.addEventListener(Event.CLOSE, onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);  
		}
		
		protected function onSocketData(e:ProgressEvent):void {
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
			var tempStr:String = temp.readUTFBytes(temp.bytesAvailable);
			var endSymbol:String = getEndSymbol(tempStr);
			
			if (tempStr.indexOf(endSymbol) != -1) {
				onResponce(answer)
				answer.clear();	
			}
		}
		
		protected function getEndSymbol(tcpStr:String):String {
			var headers:Array = URLResponse.getHeaders(tcpStr);
			if (URLResponse.isChunked(headers)) {
				return END_SYMBOL_CHUNKED;
			}else {
				return END_SYMBOL;
			}
		}
		
		protected function onResponce(bytes:ByteArray):void {
			try {
				_response = new URLResponse(bytes, request);
				//trace('onResponce : ' + _response.body);
				dispatchEvent(new URLLoaderEvent(URLLoaderEvent.COMPLETE, _response));
			}catch (err:Error){
				dispatchEvent(new URLLoaderEvent(URLLoaderEvent.ERROR, _response));
			}
		}
		
		protected function socketHasData():Boolean {
			return (socket && socket.connected && socket.bytesAvailable);
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void {
			// abstract
			dispatchEvent(new URLLoaderEvent(URLLoaderEvent.ERROR, request));
		}
		
		protected function onIOError(e:IOErrorEvent):void {
			// abstract
			dispatchEvent(new URLLoaderEvent(URLLoaderEvent.ERROR, request));
		}
		
		protected function onClose(e:Event):void {
			// abstract
			//trace('onClose');
		}
		
		protected function onConnect(e:Event):void {
			dispatchEvent(e);
		}
		
		public function get ready():Boolean { return socket && socket.connected ; }
		
		public function close():void {
			trace('CLOSE');
			if (socket.connected) {
				socket.close();
			}
			destroyResponce();
			request = null;
		}
		
		public function load(request:URLRequest):void {
			this.request = request;
			uri = new URI(request.url);
			destroyResponce();
			sendRequest(request);
		}
		
		private function destroyResponce():void {
			if (_response) {
				_response.destroy();
				_response = null;
			}
		}
		
		public function destroy():void {
			if (_destroyed) return;
			_destroyed = true;
			close()
			socket.removeEventListener(Event.CONNECT, onConnect);       
			socket.removeEventListener(Event.CLOSE, onClose);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);  
			socket = null;
			temp.clear();
			answer.clear();
			temp = answer = null;
			request = null;
			_response.destroy();
			_response = null;
		}
		
		/**
		 * Send request.
		 * @param request Request to write
		 */
		protected function sendRequest(request:URLRequest):void {
			if (ready) {
				doSendRequest(request);
			}else {
				connect(request);
			}
		}
		
		protected function doSendRequest(request:URLRequest):void {
			//trace('doSendRequest');
			var requestBytes:ByteArray = request.toByteArray();
			requestBytes.position = 0;
			// Debug
			//var hStr:String = "Header:\n" + requestBytes.readUTFBytes(requestBytes.length);
			//trace('socket.connected : ' + socket.connected);
			socket.writeBytes(requestBytes);      
			socket.flush();
		}
		
		public function connect(request:URLRequest):void {
			var uri:URI = new URI(request.url);
			socket.connect(uri.authority, DEFAULT_HTTP_PORT);
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
		
		public function get response():URLResponse {
			return _response;
		}
	}
}