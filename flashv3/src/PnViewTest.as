package  {
	import com.pubnub.*;
	import com.pubnub.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;

import mx.controls.listClasses.AdvancedListBase;

/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class PnViewTest extends Sprite {
		
		private var view:ViewGfx;
		
		public function PnViewTest() {
			super();
			if (stage) {
				init();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			view = new ViewGfx();
			addChild(view);
			
			view.subsBtn.addEventListener(MouseEvent.CLICK, onSubscribeClick);
			view.unsubBtn.addEventListener(MouseEvent.CLICK, onUnSubscribeClick);
			view.unsubAllBtn.addEventListener(MouseEvent.CLICK, onUnsubscribeAllClick);
		}	
		
		private function onUnsubscribeAllClick(e:MouseEvent):void {
			Pn.unsubscribeAll();
		}
		
		private function onUnSubscribeClick(e:MouseEvent):void {
			var channels:Array = view.unsubChannelsTxt.text.split(',');
			for each(var i:String  in channels) {
				Pn.unsubscribe(i);
			}
		}
		
		private function onSubscribeClick(e:MouseEvent):void {
			var config:Object = {
				push_interval:0.5,
				publish_key:view.publishKeyTxt.text,
				sub_key:view.subscribeKeyTxt.text,
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
			var channels:Array = view.subChannelsTxt.text.split(',');
			for each(var i:String  in channels) {
				Pn.subscribe(i);
			}
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
			//trace('ExternalInterface.call : ' + rest);
			if (ExternalInterface.available) {
				ExternalInterface.call(functionName, rest);
			}
			view.consoleTxt.appendText(rest + '\n');
		}
	}
}