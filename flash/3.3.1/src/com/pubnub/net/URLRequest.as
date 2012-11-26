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
	
		
		public function URLRequest(url:String = null) {
			_url = url;
			// Create default header
			loadDefaultHeaders();
		}
    
		/**
		 * Include headers here that are global to every request.
		 */
		protected function loadDefaultHeaders():void {
			_header = new URLRequestHeader();
			//addHeader("Connection", "close");      
			_header.add("Connection", "Keep-Alive");      
			//addHeader("Accept-Encoding", "gzip, deflate");
			//addHeader("Accept-Language", "en-us");            
			//addHeader("User-Agent", "as3httpclientlib 0.1");
			//addHeader("Accept", "*/*");
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
		
		/**
		 * Get header.
		 *
		 *  TODO: There is alot of escaping here. Don't think URI class expects to get escaped values out in pieces
		 *  It only gives you fully escape on full URI toString.
		 */
		public function getHeader(uri:URI):ByteArray {
			
			uri.forceEscape();      
			var bytes:ByteArray = new ByteArray();
			var path:String = uri.path;
			if (!path) path = "/";
			else path = URI.fastEscapeChars(path, kUriPathEscapeBitmap);
			
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
			bytes.writeUTFBytes(_method + " " + path + " HTTP/" + version + "\r\n");
			bytes.writeUTFBytes("Host: " + host + "\r\n");
			
			if (!header.isEmpty) {
				bytes.writeUTFBytes(header.content);
			}
			
			bytes.writeUTFBytes("\r\n");
			bytes.position = 0;
			return bytes;
		}
		
		public function toString():String {
			return "method: " + _method + ", header: " + _header;
		}
	}
}