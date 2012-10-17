package com.pubnub.operation {
	import com.pubnub.loader.PnURLLoaderEvent;
	import com.pubnub.PnCrypto;
	import com.pubnub.PnUtils;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class HistoryOperation extends Operation {
		
		public var sub_key:String;
		public var origin:String;
		public var cipherKey:String;
		
		override public function send(args:Object):void {
			//trace(this, 'sub_key : ' + sub_key);
			channel = args.channel;
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
			//trace(result);
            return result;
        }
		
		override protected function onLoaderData(e:PnURLLoaderEvent):void {
			var data:* = e.data;
			//var test:Object = JSON.parse(data);
			try {
				var result:Object = JSON.parse(data);
				var messages:Array = [];
				var mess:Object;
				if(result) {
					for (var i:int = 0; i < result[0].length; i++) {
						if (cipherKey.length > 0) {
							mess = [i + 1, PnCrypto.decrypt(cipherKey, result[0][i])];
						}else {
							mess = [i + 1, JSON.stringify(result[0][i])];
						}    
						messages.push(mess);
					}
					dispatchEvent(new OperationEvent(OperationEvent.RESULT, messages));
				}
			}
			catch (e:*){
				dispatchEvent(new OperationEvent(OperationEvent.FAULT, [0, "[PubNub detailed history] Bad Data Content Ignored"] ));
			}
		}
	}
}