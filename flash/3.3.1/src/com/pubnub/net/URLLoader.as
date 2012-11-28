package com.pubnub.net {
	import com.adobe.net.URI;
	import com.pubnub.loader.PnURLLoaderEvent;
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
		
		public var keepAlive:Boolean;
		private var socket:Socket;
		private var uri:URI;
		private var request:URLRequest;
		private var responseBuffer:HttpResponseBuffer;
		private var answer:ByteArray = new ByteArray();
		private var temp:ByteArray = new ByteArray();
		private const END:String = '0\r\n';
		private const parser:HTTPParser = new HTTPParser();
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
			
			//answer.position = 0;
			temp.position = 0;
			var tempStr:String = temp.readUTFBytes(temp.bytesAvailable)
			if (tempStr.indexOf(END) != -1) {
				
				if (keepAlive == false) {
					close();
				}
				try {
					parser.rawData = answer.readUTFBytes(answer.bytesAvailable);
					_data = parser.body;
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
			//trace(this, 'onSecurityError');
			dispatchEvent(e);
		}
		
		private function onIOError(e:IOErrorEvent):void {
			//trace(this, 'onIOError');
			dispatchEvent(e);
		}
		
		private function onClose(e:Event):void {
			//trace('onClose');
			if (keepAlive) {
				socket.connect(uri.authority, HttpSocket.DEFAULT_HTTP_PORT);
			}
			//dispatchEvent(e);
		}
		
		private function onConnect(e:Event):void {
			//trace('onConnect');
			_connectPending = false;
			sendRequest(uri, request);
		}
		
		
		public function close():void {
			//trace('CLOSE');
			if (socket.connected) {
				
				socket.close();
			}
		}
		
		public function load(url:String):void {
			trace('load : ' + url);
			_data = null;
			uri = new URI(url);
			request = new URLRequest(url);
			request.method = URLRequestMethod.GET;
			//request.header = new URLRequestHeader([ { name: "Connection", value: "Keep-Alive" } ]);
			if (socket.connected) {
				sendRequest(uri, request);
			}else {
				if (_connectPending) return;
				socket.connect(uri.authority, HttpSocket.DEFAULT_HTTP_PORT); 
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
			dispatchEvent(new Event(Event.OPEN));
		}
		
		private function onRequestComplete(request:URLRequest, header:String):void {
			//dispatchEvent(new HttpRequestEvent(request, header));
		}
		
		private function onResponseHeader(response:HttpResponse):void {
			//trace('onResponseHeader');
			//Log.debug("Response: " + response.code);
			//dispatchEvent(new HttpStatusEvent(response));
		}
		
		private function onResponseData(bytes:ByteArray):void {
			var str:String = bytes.readUTFBytes(bytes.bytesAvailable);
			//trace('onResponseData : ' + str);
			bytes.position = 0;
			dispatchEvent(new HttpDataEvent(bytes));
			dispatchEvent(new PnURLLoaderEvent(PnURLLoaderEvent.COMPLETE, str));
		}
		
		private function onResponseComplete(response:HttpResponse):void {
			//trace('onResponseComplete');
			//Log.debug("Response complete");
			//if (!(_socket is TLSSocket)) close(); // Don't close TLSSocket; it has a bug I think
			//close();
			//onComplete(response);
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}

class HTTPParser {
	
	private var _rawData:String;
	private var _version:String;
	private var _code:String;
	private var _message:String;
	private var _body:String;
	private var _headers:Array;
	private const END_LINE:String = '\r\n';
	
	public function HTTPParser(rawData:String = null):void {
		parse(rawData);
	}
	
	private function parse(data:String):void {
		//trace(data);
		//trace('--------------------------------------');
		dispose();
		if (!data) return;
		_rawData = data;
		_headers ||= new Array();
		parseHeader();
		parseBody();
	}
	
	private function parseBody():void {
		if (isSuccess == false) return;
		_body = '';
		var separator:String = END_LINE + END_LINE
		var ind:int = _rawData.indexOf(separator);
		var bodyRawStr:String = _rawData.substr(ind + separator.length, _rawData.length);
		
		var lines:/*String*/Array = bodyRawStr.split(END_LINE);
		var len:int = lines.length;
		var i:int = 0;
		for (i; i < len; i++) {
			var size:int= int(lines[i]);
			var data:String = lines[i+1];
			if (size > 0) {
				_body += data;
				i++;
			}else {
				// end of body data
				break;
			}
		}
	}
	
	/**
     * Parse HTTP response header.
     * @param lines Lines in header
     * @return The HTTP response so far
     */
	protected function parseHeader():void {
		var ind:int = _rawData.indexOf(END_LINE + END_LINE);
		var headersRawStr:String = _rawData.substr(0, ind);
		var lines:/*String*/Array = headersRawStr.split(END_LINE);
		var firstLine:String = lines[0];
		//trace('headersRawStr : ' + headersRawStr);
		// Regex courtesy of ruby 1.8 Net::HTTP
		// Example, HTTP/1.1 200 OK      
		var matches:Array = firstLine.match(/\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)\s*(.*)\z/);
		if (matches) {
			_version = matches[1];
			_code = matches[2];
			_message = matches[3];
		}else {
			//throw new Error("Invalid header: " + firstLine + ", matches: " + matches);
			trace("Invalid header: " + firstLine + ", matches: " + matches);
		}
		
		var line:String;
		for (var i:Number = 1; i < lines.length; i++) {
			line = lines[i];
			ind = line.indexOf(":");
			if (ind != -1) {
				var name:String = line.substring(0, ind);
				var value:String = line.substring(ind + 1, line.length);
				_headers.push( { name: name, value: value } );
			} else {
				trace("Invalid header: " + line);
			}
		}
	}	
    
	public function get isSuccess():Boolean { return _code.search(/\A2\d\d/) != -1; } // 2xx
	
	public function set rawData(value:String):void {
		parse(value);
	}
	
	public function get rawData():String {
		return _rawData;
	}
	
	public function get version():String {
		return _version;
	}
	
	public function get code():String {
		return _code;
	}
	
	public function get body():String {
		return _body;
	}
	
	public function get headers():Array {
		return _headers;
	}
	
	public function get message():String {
		return _message;
	}
	
	public function dispose():void {
		_version = null;
		_code = null;
		_body = null;
		_rawData = null;
		_message = null;
		if (_headers) _headers.length = 0;
	}
	
	public function destroy():void {
		dispose();
		_headers = null;
	}
	
	
	
	
}