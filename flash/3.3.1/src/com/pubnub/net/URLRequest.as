/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package com.pubnub.net {
	
	import com.adobe.net.*;
	import flash.net.URLRequestMethod;
	import flash.utils.*;
	
	
	public class URLRequest {
		private var version:String = '1.1';
		
		public static const kUriPathEscapeBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %?#");
		public static const kUriQueryEscapeBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %=|:?#/@+\\"); // Probably don't need to escape all these
    
		// Request method. For example, "GET", "POST"
		protected var _method:String = URLRequestMethod.GET;
    
		// Request header
		protected var _header:URLRequestHeader;
    
		// url
		protected var _url:String;
		protected var uri:URI;
	
		
		public function URLRequest(url:String = null) {
			_url = url;
			uri = new URI(url);
			// Create default header
			loadDefaultHeaders();
		}
    
		/**
		 * Include headers here that are global to every request.
		 */
		protected function loadDefaultHeaders():void {
			_header = new URLRequestHeader();
			_header.add("Connection", "Keep-Alive"); 
		}
		
		public function destroy():void {
			_header.destroy();
			_header = null;
		}
		
		/**
		 * Set content type.
		 * @param contentType
		 */
		public function set contentType(contentType:String):void {
		  _header.replace("Content-Type", contentType);
		}
		
		public function get header():URLRequestHeader {
			return _header;
		}
		
		public function set header(value:URLRequestHeader):void {
			_header = value;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set method(value:String):void {
			_method = value;
		}
		
		public function toByteArray():ByteArray{
			uri.forceEscape();      
			var result:ByteArray = new ByteArray();
			var path:String = uri.path;
			if (!path) {
				path = "/";
			}
			else {
				path = URI.fastEscapeChars(path, kUriPathEscapeBitmap);
			}
			
			// Escape params manually; and escape alot
			var query:Object = uri.getQueryByMap();
			var params:Array = [];
			for (var key:String in query) {
				var escapedKey:String = URI.fastEscapeChars(key, kUriQueryEscapeBitmap);
				var escapedValue:String = URI.fastEscapeChars(query[key], kUriQueryEscapeBitmap);
				params.push(escapedKey + "=" + escapedValue);
			}      
			
			if (params.length > 0) path += "?" + params.join("&");      
			
			var host:String = uri.authority;
			if (uri.port) host += ":" + uri.port;
			result.writeUTFBytes(_method + " " + path + " HTTP/" + version + "\r\n");
			result.writeUTFBytes("Host: " + host + "\r\n");
			
			if (!_header.isEmpty) {
				result.writeUTFBytes(_header.content);
			}
			
			result.writeUTFBytes("\r\n");
			result.position = 0;
			return result;
		}
		
		public function toString():String {
			return "method: " + _method + ", header: " + _header;
		}
	}
}