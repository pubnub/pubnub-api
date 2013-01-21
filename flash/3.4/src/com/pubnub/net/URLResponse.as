package com.pubnub.net {
	import com.pubnub.log.Log;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class URLResponse {
		
		private var _rawData:String;
		private var _version:String;
		private var _code:String;
		private var _message:String;
		private var _body:String;
		private var _headers:Array;
		private var _isChunked:Boolean;
		public static const END_LINE:String = '\r\n';
		
		private var _request:URLRequest;
		
		public function URLResponse(bytes:ByteArray = null, request:URLRequest = null) {
			_request = request;
			fromBytesArray(bytes);
		}
		
		
		public function fromBytesArray(bytes:ByteArray):void {
			if (!bytes) return;
			bytes.position = 0;
			_rawData = bytes.readUTFBytes(bytes.bytesAvailable);
			_headers ||= new Array();
			parseHeader();
			parseBody();
		}
		
		/**
		 * Parse HTTP response header.
		 * @param lines Lines in header
		 * @return The HTTP response so far
		 */
		protected function parseHeader():void {
			var ind:int = _rawData.indexOf(END_LINE + END_LINE);
			var rawString:String = _rawData.substr(0, ind);
			
			_headers = getHeaders(rawString);
			_isChunked = isChunked(_headers);
			var lines:/*String*/Array = rawString.split(END_LINE);
			var firstLine:String = lines[0];

			// Regex courtesy of ruby 1.8 Net::HTTP
			// Example, HTTP/1.1 200 OK      
			var matches:Array = firstLine.match(/\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)\s*(.*)\z/);
			if (matches) {
				_version = matches[1];
				_code = matches[2];
				_message = matches[3];
			}else {
				Log.log(this + "Invalid header: " + firstLine + ", matches: " + matches, Log.ERROR);
				trace(this + "Invalid header: " + firstLine + ", matches: " + matches);
			}
		}
		
		private function parseBody():void {
			if (isSuccess == false) return;
			_body = '';
			var separator:String = END_LINE + END_LINE
			var ind:int = _rawData.indexOf(separator);
			var bodyRawStr:String = _rawData.substr(ind + separator.length, _rawData.length);

            isChunked(headers);

			if (_isChunked) {
				var lines:/*String*/Array = bodyRawStr.split(END_LINE);
				var len:int = lines.length;
				var i:int = 0;
				for (i; i < len; i++) {
					var size:int= int("0x" + lines[i]);
					var data:String = lines[i+1];
					if (size > 0) {
						_body += data;
						i++;
					}else {
						// end of body data
						break;
					}
				}
			}else {
				_body = bodyRawStr;
			}
		}

        //TODO: Refactor into URLLoader getEndSymbol

		static public function isChunked(headers:Array):Boolean{
			if (headers && headers.length > 1) {
				for each(var o:Object  in headers) {
					var name:String = String(o.name).toLowerCase();
					var value:String = String(o.value).toLowerCase();
					if (name == 'transfer-encoding' && value == 'chunked') {
						return true;
					}
				}
			}
			return false;
		}
		
		static public function getHeaders(str:String):Array {
			var result:Array = [];
			var ind:int = str.indexOf(END_LINE + END_LINE);
			if (ind > -1) {
				return null;
			}
			var headerString:String = str.substr(0, ind);
			var lines:/*String*/Array = str.split(END_LINE);
			var line:String;
			for (var i:Number = 1; i < lines.length; i++) {
				line = lines[i];
				ind = line.indexOf(":");
				if (ind != -1) {
					var name:String = line.substring(0, ind);
					var value:String = line.substring(ind + 1, line.length);
					result.push( { name: name, value: value.replace(/^ /,"") } );
                    //result.add(name,value.replace(/^ /,""));

                } else {
					trace("[URLResponse] Invalid header: " + line);
					Log.log("[URLResponse] Invalid header: " + line, Log.ERROR);
				}
			}
			return result;
		}
		
		
		public function get isSuccess():Boolean { return _code.search(/\A2\d\d/) != -1; } // 2xx
	
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
		
		public function get request():URLRequest {
			return _request;
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
}