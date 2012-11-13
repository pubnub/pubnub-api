package {
	import com.pubnub.*;
	import flash.display.*;
	import flash.external.*;
	import flash.utils.*;

	/*
	 * Simple pure AS3 demo
	 * 
	 * */
	public class PubNubAS3Example extends Sprite {

		// base vars
        public var channel:String = 'my_channel';
        public var origin:String = 'pubsub.pubnub.com';
        public var pub_key:String = 'demo';
        public var sub_key:String = 'demo';
        public var secret_key:String = '';
        public var cipher_key:String = '';
        public var ssl:Boolean = true;
		
		public function PubNubAS3Example():void {
			super();
			init();
		}
		
		private function init():void {
			 var config:Object = {
                origin:		this.origin,
                publish_key:this.pub_key,
                sub_key:	this.sub_key,
                secret_key:	this.secret_key,
                cipher_key:	this.cipher_key,
                ssl:		this.ssl}
			
			Pn.instance.addEventListener(PnEvent.INIT, onInit);
            Pn.instance.addEventListener(PnEvent.INIT_ERROR, onInitError);
            Pn.instance.addEventListener(PnEvent.SUBSCRIBE, onSubscribe);
            Pn.init(config);
		}
		
		private function onInitError(e:PnEvent):void {
			callExternalInterface("console.log", ("onInitError"));
		}
		
		private function onInit(e:PnEvent):void {
			callExternalInterface("console.log", ("Pn init : " + Pn.instance.sessionUUID));
			Pn.subscribe(channel);
			// unsubscribe
			setTimeout(unsubscribe, 20000, channel);
		}
		
		private function unsubscribe(channelName:String):void {
			Pn.unsubscribe(channelName);
		}
		
		 private function onSubscribe(e:PnEvent):void {

            switch (e.status) {
                case OperationStatus.DATA:
                    callExternalInterface("console.log", ("Subscribe [DATA], channel : " + e.channel + ', result : ' + e.data.result));
                    break;

                case OperationStatus.CONNECT:
                    callExternalInterface("console.log", ("Subscribe [CONNECT] : " + e.channel));
                    break;

                case OperationStatus.DISCONNECT:
                    callExternalInterface("console.log", ("Subscribe [DISCONNECT] : " + e.channel));
                    break;

                case OperationStatus.ERROR:
                    callExternalInterface("console.log", ("Subscribe [ERROR] : " + e.channel + ', ' + e.data));
                    break;
            }
        }
		
		private function callExternalInterface(functionName:String, ...rest):void {
			trace('ExternalInterface.call : ' + rest);
			if (ExternalInterface.available) {
				ExternalInterface.call(functionName, rest);
			}
		}
	}
}
