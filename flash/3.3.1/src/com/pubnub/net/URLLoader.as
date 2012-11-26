package com.pubnub.net {
	import com.adobe.net.URI;
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpRequestEvent;
	import org.httpclient.events.HttpStatusEvent;
	import org.httpclient.HttpRequest;
	import org.httpclient.HttpResponse;
	import org.httpclient.HttpSocket;
	import org.httpclient.io.HttpResponseBuffer;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class URLLoader extends EventDispatcher {
		private var socket:Socket;
		private var uri:URI;
		private var request:URLRequest;
		private var responseBuffer:HttpResponseBuffer;
		
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
			
			while (socketHasData()) {        
				//_timer.reset();
				try {           
					// Load data from socket
					var bytes:ByteArray = new ByteArray();
					socket.readBytes(bytes, 0, socket.bytesAvailable);                       
					bytes.position = 0;
					
					// Write to response buffer
					responseBuffer.writeBytes(bytes);
					//var ct:Number = getTimer();
					//trace('onSocketData : ' + (ct - temp));
				} catch(e:EOFError) {
					//Log.debug("EOF");
					//_dispatcher.dispatchEvent(new HttpErrorEvent(HttpErrorEvent.ERROR, false, false, "EOF", 1));          
					//break;
				}                           
			}
			trace('onSocketData');
			//trace(responseBuffer.header)
		}
		
		private function socketHasData():Boolean {
			return (socket && socket.connected && socket.bytesAvailable);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			
		}
		
		private function onIOError(e:IOErrorEvent):void {
			
		}
		
		private function onClose(e:Event):void {
			trace('onClose');
		}
		
		private function onConnect(e:Event):void {
			trace('onConnect');
			sendRequest(uri, request);
		}
		
		
		public function close():void {
			if (socket.connected) {
				socket.close();
			}
		}
		
		public function load(url:String):void {
			uri = new URI(url);
			request = new URLRequest(url);
			request.method = URLRequestMethod.GET;
			request.header = new URLRequestHeader([ { name: "Connection", value: "Keep-Alive" } ]);
			
			if (socket.connected) {
				sendRequest(uri, request);
			}else {
				socket.connect(uri.authority, HttpSocket.DEFAULT_HTTP_PORT); 
			}
		}
		
		
		/**
		 * Send request.
		 * @param uri URI
		 * @param request Request to write
		 */
		protected function sendRequest(uri:URI, request:URLRequest):void {  
			// Prepare response buffer
			responseBuffer = new HttpResponseBuffer(true, onResponseHeader, onResponseData, onResponseComplete);
			//Log.debug("Request URI: " + uri + " (" + request.method + ")");
			var headerBytes:ByteArray = request.getHeader(uri);
			
			// Debug
			var hStr:String = "Header:\n" + headerBytes.readUTFBytes(headerBytes.length);
			//trace(hStr);
			headerBytes.position = 0;
		  
			socket.writeBytes(headerBytes);      
			socket.flush();
			
			//Log.debug("Send request done");
			headerBytes.position = 0;
			onRequestComplete(request, headerBytes.readUTFBytes(headerBytes.length));
		}
		
		private function onRequestComplete(request:URLRequest, header:String):void {
			//dispatchEvent(new HttpRequestEvent(request, header));
		}
		
		private function onResponseHeader(response:HttpResponse):void {
			trace('onResponseHeader');
			//Log.debug("Response: " + response.code);
			//dispatchEvent(new HttpStatusEvent(response));
		}
		
		private function onResponseData(bytes:ByteArray):void {
			trace('onResponseData : ' + bytes.readUTFBytes(bytes.bytesAvailable));
			//dispatchEvent(new HttpDataEvent(bytes));
		}
		
		private function onResponseComplete(response:HttpResponse):void {
			trace('onResponseComplete');
			//Log.debug("Response complete");
			//if (!(_socket is TLSSocket)) close(); // Don't close TLSSocket; it has a bug I think
			//close();
			//onComplete(response);
		}
	}

}