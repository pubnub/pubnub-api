package com.pubnub.net {
	
	import com.adobe.utils.StringUtil;
	
	public class URLRequestHeader {
		
		public static const KEEP_ALIVE:String = "Keep-Alive";
		public static const CONNECTION:String = "Connection";
		
		private var _headers:Array;
		
		public function URLRequestHeader() {
			_headers = [{ name: CONNECTION, value: KEEP_ALIVE }];
		}
		
		public function destroy():void {
			_headers = null;
		}
		
		public function get isEmpty():Boolean { 
			return _headers ? _headers.length == 0 : true; 
		}
		
		public function get content():String {
			var data:String = "";
			for each(var prop:Object in _headers) {
				data += prop["name"] + ": " + prop["value"] + "\r\n";
			}
			return data;
		}
		
		public function getValue(name:String):String {
			var prop:Object = find(name);
			if (prop) return prop["value"];
			return null;	
		}
		
		
		private function find(name:String):Object {
			var index:int = indexOf(name);
			if (index != -1) return _headers[index];
			return null;
		}
		
		
		private function indexOf(name:String):int {  
			name = name.toLowerCase();
			for (var i:int = 0; i < _headers.length; i++) {
				if (_headers[i]["name"].toLowerCase() == name) return i;
			}
			return -1;
		}
		
		
	}
}