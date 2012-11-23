package com.pubnub.operation {
	import com.adobe.crypto.*;
	import com.adobe.net.URI;
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.loader.*;
	import flash.utils.getTimer;
	import org.httpclient.HttpHeader;
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class PublishOperation extends Operation {
		 
		public var secretKey:String; 
		public var cipherKey:String = ""; 
		public var publishKey:String = ""; 
		
		
		private var expLoader:ExperimentURLLoader;
		
		override public function send(args:Object):void {
			//var temp:Number = getTimer();
			channel = args.channel;
			var message:String = args.message;
			if (channel == null || message == null) {
				dispatchEvent(new OperationEvent(OperationEvent.FAULT, [ -1, "Channel Not Given and/or Message"]));
				return;
			}
			var signature:String = "0";
			var serializedMessage:String = PnJSON.stringify(message);
			if (secretKey){
				// Create the signature for this message                
				var concat:String = publishKey + "/" + subscribeKey + "/" + secretKey + "/" + channel + "/" + serializedMessage;
				
				// Sign message using HmacSHA256
				signature = HMAC.hash(secretKey, concat, SHA256);        
			}
			
			if(cipherKey && cipherKey.length > 0){
				serializedMessage = PnJSON.stringify(PnCrypto.encrypt(cipherKey, serializedMessage));
			}
			
			uid = PnUtils.getUID();
			_url = origin + "/" + "publish" + "/" + publishKey + "/" + subscribeKey + "/" + signature + "/" + PnUtils.encode(channel) + "/" + 0 + "/" +PnUtils.encode(serializedMessage as String);
			//trace(getTimer() - temp);
			_loader.load(this._url);
			
			//var uri:URI = new URI(url);
			//expLoader ||= new ExperimentURLLoader();
			//expLoader.load(uri);
		}
		
		override protected function onLoaderData(e:PnURLLoaderEvent):void {
			try {
				dispatchEvent(new OperationEvent(OperationEvent.RESULT, PnJSON.parse(String(e.data))));
			}
			catch (e:*){
				dispatchEvent(new OperationEvent(OperationEvent.FAULT, [-1, "[Pn.publish()] JSON.parse error"] ));
			}
		}
	}
}