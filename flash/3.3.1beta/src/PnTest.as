package {
	import com.pubnub.*;
	import com.pubnub.events.*;
	import flash.display.*;
	import flash.external.*;
	import flash.utils.*;

	

	public class PnTest extends Sprite {

		private var channel:String = 'hello_world';
		private var channel2:String = 'another_world';
		
		public function PnTest():void {
			super();
			init();
		}
		
		private function init():void {
			var config:Object = {
				push_interval:0.5,
				publish_key:"demo",
				sub_key:"demo",
				secret_key:"",
				cipher_key:null
			}
			Pn.init(config);
			Pn.instance.addEventListener(PnEvent.INIT, onInit);
			Pn.instance.addEventListener(PnEvent.INIT_ERROR, onInitError);
			Pn.instance.addEventListener(SubscribeEvent.SUBSCRIBE, onSubscribe);
		}
		
		private function onInitError(e:PnEvent):void {
			callExternalInterface("console.log", ("onInitError"));
		}
		
		private function onInit(e:PnEvent):void {
			callExternalInterface("console.log", ("Pn init : " + Pn.instance.sessionUUID));
			Pn.subscribe(channel);
			Pn.subscribe(channel2);
			
			// independance unsubscribe
			setTimeout(unsubscribe, 20000, channel);
			setTimeout(unsubscribe, 20000, channel2);
			
			// total unsubscribe
			//setTimeout(Pn.unsubscribeAll, 5000);
		}
		
		private function unsubscribe(channelName:String):void {
			Pn.unsubscribe(channelName);
		}
		
		private function onSubscribe(e:SubscribeEvent):void {
			
			switch (e.status) {
				case SubscribeStatus.DATA:
					callExternalInterface("console.log", ("[DATA], channel : " + e.channel + ', result : ' + e.data.result));
					break;
			
				case SubscribeStatus.CONNECT:
					callExternalInterface("console.log", ("[CONNECT] : " + e.channel));
					break;
			
				case SubscribeStatus.DISCONNECT:
					callExternalInterface("console.log", ("[DISCONNECT] : " + e.channel));
					break;
					
				case SubscribeStatus.ERROR:
					callExternalInterface("console.log", ("[ERROR] : " + e.channel));
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
