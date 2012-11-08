package com.pubnub.operation {
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.loader.*;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class HistoryOperation extends Operation {
		
		public var sub_key:String;
		public var cipherKey:String;
		
		override public function send(args:Object):void {
			channel = args.channel;
			sub_key = args['sub-key'];
			_url = origin + "/v2/history/sub-key/" + sub_key + "/channel/" + PnUtils.encode(args.channel); 
			if (args.start || args.end || args.reverse || args.count) {
				_url += extractOptionalParams(args);
            }
			_loader.load(_url);
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
		
		override protected function onLoaderData(e:PnURLLoaderEvent):void {
			var data:* = e.data;
			try {
				var result:Object = PnJSON.parse(data);
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
	}
}