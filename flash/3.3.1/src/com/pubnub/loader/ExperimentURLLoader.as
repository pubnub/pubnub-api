package com.pubnub.loader {
	import com.adobe.net.URI;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpRequestEvent;
	import org.httpclient.events.HttpStatusEvent;
	import org.httpclient.http.Get;
	import org.httpclient.HttpHeader;
	import org.httpclient.HttpRequest;
	import org.httpclient.HttpResponse;
	import org.httpclient.HttpSocket;
	import org.httpclient.io.HttpRequestBuffer;
	import org.httpclient.io.HttpResponseBuffer;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class ExperimentURLLoader extends EventDispatcher {
		
		
		private var socket:Socket;
		private var request:HttpRequest;
		private var uri:URI;
		private var requestBuffer:HttpRequestBuffer;
		private var responseBuffer:HttpResponseBuffer;
		private var time:Number
		
		public function ExperimentURLLoader() {
			super(null);
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);       
			socket.addEventListener(Event.CLOSE, onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);  
		}
		
		private function onSocketData(e:ProgressEvent):void {
			trace('onSocketData');
			/*while (socket.connected && socket.bytesAvailable) {        
				//_timer.reset();
				try {           
          
          // Load data from socket
          var bytes:ByteArray = new ByteArray();
          _socket.readBytes(bytes, 0, _socket.bytesAvailable);                       
          bytes.position = 0;
          
          // Write to response buffer
          _responseBuffer.writeBytes(bytes);
		  var ct:Number = getTimer();
          //trace('onSocketData : ' + (ct - temp));
        } catch(e:EOFError) {
          Log.debug("EOF");
          _dispatcher.dispatchEvent(new HttpErrorEvent(HttpErrorEvent.ERROR, false, false, "EOF", 1));          
          break;
        }                           
      }*/
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace('onSecurityError');
		}
		
		private function onIOError(e:IOErrorEvent):void {
			trace('onIOError');
		}
		
		private function onClose(e:Event):void {
			trace('onClose');
		}
		
		private function onConnect(e:Event):void {
			trace('onConnect : ' + (getTimer() - time ));
			
			doRequest();
		}
		
		
		public function load(uri:URI):void {
			//trace
			time = getTimer();
			request = new Get(new HttpHeader(PnURLLoader.headers));
			this.uri = uri;
			this.request = request;
			//trace('socket.connected : ' + socket.connected);
			trace(uri.authority);
			if (socket.connected) {
				doRequest();
			}else {
				socket.connect(uri.authority, HttpSocket.DEFAULT_HTTP_PORT); 
			}
		}
		
		public function close():void {
			socket.close();
		}
		
		private function doRequest():void {
			sendRequest(uri, request);
		}
			/**
		 * Send request.
		 * @param uri URI
		 * @param request Request to write
		 */
		protected function sendRequest(uri:URI, request:HttpRequest):void {  
			// Prepare response buffer
			responseBuffer = new HttpResponseBuffer(request.hasResponseBody, onResponseHeader, onResponseData, onResponseComplete);
			//Log.debug("Request URI: " + uri + " (" + request.method + ")");
			var headerBytes:ByteArray = request.getHeader(uri, null, HttpSocket.HTTP_VERSION);
			
			// Debug
			var hStr:String = "Header:\n" + headerBytes.readUTFBytes(headerBytes.length);
			//trace(hStr);
			//Log.level = Log.DEBUG;
			//Log.debug(hStr);
			headerBytes.position = 0;
		  
			socket.writeBytes(headerBytes);      
			socket.flush();
			//_timer.reset();
			
			if (request.hasRequestBody) {
				requestBuffer = new HttpRequestBuffer(request.body);
				
				while (requestBuffer.hasData) {
					var bytes:ByteArray = requestBuffer.read();
					if (bytes.length > 0) {
						socket.writeBytes(bytes);
						//_timer.reset();
						
						// We are totally fucked.
						// https://bugs.adobe.com/jira/browse/FP-6
						socket.flush();
					}
				}
			}
			//Log.debug("Send request done");
			headerBytes.position = 0;
			onRequestComplete(request, headerBytes.readUTFBytes(headerBytes.length));
		}
		
		
		private function onRequestComplete(request:HttpRequest, header:String):void {
			dispatchEvent(new HttpRequestEvent(request, header));
		}
		
		private function onResponseHeader(response:HttpResponse):void {
			//Log.debug("Response: " + response.code);
			dispatchEvent(new HttpStatusEvent(response));
		}
		
		private function onResponseData(bytes:ByteArray):void {
			dispatchEvent(new HttpDataEvent(bytes));
		}
		
		private function onResponseComplete(response:HttpResponse):void {
			//Log.debug("Response complete");
			//if (!(_socket is TLSSocket)) close(); // Don't close TLSSocket; it has a bug I think
			close();
			//onComplete(response);
			
		}
	}
}