package com.pubnub.operation {
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.net.*;
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class HistoryOperation extends Operation {
		private var _channel:String;
		public var sub_key:String;
		public var cipherKey:String;
		
		public function HistoryOperation(origin:String):void {
			super(origin);
		}
		
		override public function setURL(url:String = null, args:Object = null):URLRequest {
			_channel = args.channel;
			sub_key = args['sub-key'];
			_url = origin + "/v2/history/sub-key/" + sub_key + "/channel/" + PnUtils.encode(args.channel); 
			if (args.start || args.end || args.reverse || args.count) {
				_url += extractOptionalParams(args);
            }
			return createRequest();
		}
		
		private function extractOptionalParams(args:Object):String {
			var result:String = '?';
            var optionalParams:Object = {};

            if (args.start != null) {
                optionalParams["start"] = args.start;
            }
            if (args.end != null) {
                optionalParams["end"] = args.end;
            }
			
			if (args.count != null) {
                optionalParams["count"] = PnUtils.encode(args.count.toString());
            }
			
            if (args.reverse != null) {
                if (args.reverse == true) {
                    optionalParams["reverse"] = true;
                } else if (args.reverse == false) {
                    optionalParams["reverse"] = false;
                }
            }

            for (var key:String in optionalParams) {
				if (result == '?') {
					result += key + "=" + optionalParams[key];
				}else {
					result += "&" + key + "=" + optionalParams[key];
				}
            }
            return result;
        }
		
		override public function onData(data:Object = null):void {
			//trace(this, 'onLoaderComplete');
			//var data:* = e.target.data;
			try {
				var result:Object = PnJSON.parse(String(data));
				var messages:Array = [];
				var mess:Object;
				if(result) {
					for (var i:int = 0; i < result[0].length; i++) {
						if (cipherKey.length > 0) {
							mess = [i + 1, PnCrypto.decrypt(cipherKey, result[0][i])];
						}else {
							mess = [i + 1, PnJSON.stringify(result[0][i])];
						}    
						messages.push(mess);
					}
					dispatchEvent(new OperationEvent(OperationEvent.RESULT, messages));
				}
			}
			catch (e:*){
				dispatchEvent(new OperationEvent(OperationEvent.FAULT, [-1, "[Pn.detailedHistory()] Bad Data Content Ignored"] ));
			}
		}
		
		public function get channel():String {
			return _channel;
		}
	}
}