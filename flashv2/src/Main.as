package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
import flash.utils.Timer;


/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Main extends Sprite {
		
		private var view:ViewGfx = new ViewGfx();

        private var url:String = 'http://localhost';
		//private var url:String = 'http://ipv4.download.thinkbroadband.com/1GB.zip';
        //private var url:String = 'http://pubsub.pubnub.com/subscribe/demo/hello_world/0/23494764498058254';
		private var urlLoader:URLLoader;
		private var urlStream:URLStream;
		private var method:String = URLRequestMethod.GET;
		
		private var loader:*;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			view = new ViewGfx();
			view.urlTxt.text = url;
			view.startBtn.addEventListener(MouseEvent.CLICK, onStartBtnClick);
			view.abortBtn.addEventListener(MouseEvent.CLICK, onAbortBtnClick);
			view.classCB.addEventListener(Event.CHANGE, onClassChange);
			view.methodCB.addEventListener(Event.CHANGE, onMethodChange);
			addChild(view);
			
			urlLoader = new URLLoader();
			urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

			loader = urlLoader;
		}
		
		private function onMethodChange(e:Event):void {
			if (view.methodCB.selectedLabel == 'GET') {
				method = URLRequestMethod.GET;
			}else {
				method = URLRequestMethod.POST;
			}
			//trace(method);
		}
		
		private function onClassChange(e:Event):void {
			if (view.classCB.selectedLabel == 'URLLoader') {
				loader = urlLoader;
			}else {
				loader = urlStream;
			}
			//trace(loader);
		}
		
		private function onAbortBtnClick(e:MouseEvent):void {
			updateStatus('Aborted');
			try {
				loader.close()
			}catch (err:Error){
				
			}
		}
		
		private function onIOError(e:IOErrorEvent):void {
			updateStatus('IOError : ' + e.errorID);
		}
		
		private function onHTTPStatus(e:HTTPStatusEvent):void {
			updateStatus('HTPP Status : ' + e.status);
		}
		
		private function onStartBtnClick(e:MouseEvent):void {
			url = view.urlTxt.text;
			var request:URLRequest = new URLRequest(url);
			request.method = method
			loader.load(request);
		}
		
		private function onLoadProgress(e:ProgressEvent):void {
			//trace(e.bytesLoaded / e.bytesTotal);
			var percent:Number = 100 * (e.bytesLoaded / e.bytesTotal);
			updateStatus('Loaded: ' + (Math.round(percent * 100) / 100) + '%');
		}
		
		private function updateStatus(string:String):void {
			view.statusTxt.text = string
		}
	}




}