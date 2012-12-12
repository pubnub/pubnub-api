package com.pubnub.subscribe {
	import com.pubnub.Errors;
	import com.pubnub.json.PnJSON;
	import com.pubnub.operation.Operation;
	import com.pubnub.operation.OperationEvent;
	import com.pubnub.PnCrypto;
	import com.pubnub.PnUtils;
	import com.pubnub.subscribe.Subscribe;
	import com.pubnub.subscribe.SubscribeEvent;
	import flash.utils.clearTimeout;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class PresenceChannel extends SubscribeChannel {
		
		public function PresenceChannel(connectionUID:String = '') {
			this.connectionUID = connectionUID;
			super();
		}
		
		override protected function connectInit():void {
			// use here connectionUID from a subcribe
			clearTimeout(pingTimeout);
			url = _origin + "/" + "subscribe" + "/" + subscribeKey + "/" + PnUtils.encode(_lastChannel) + "/" + 0;
			
			var operation:Operation = getOperation(SubscribeChannel.GET_TIMETOKEN);
			connection.sendOperation(operation);
		}
		
		override protected function leave():void {
			// no leave for a pnpres chanel
		}
		
		override protected function onConnect(e:OperationEvent):void {
            var eventData:Object = e.data;
            lastToken = eventData[1];
            var messages:Array = eventData[0];
            if (messages) {
                for (var i:int = 0; i < messages.length; i++) {
                    var msg:* = cipherKey.length > 0 ? PnJSON.parse(PnCrypto.decrypt(cipherKey, messages[i])) : messages[i];
                    _data = {
                        channel:_lastChannel,
                        result:[i + 1, msg],
                        timeout:1
                    }
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, _data));
                }
            }
			destroyOperation(e.target as Operation);
            connectLastToken();
        }		
	}
}