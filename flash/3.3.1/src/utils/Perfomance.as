package utils {
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.pubnub.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Perfomance extends EventDispatcher {
		
		public var pub_key:String = 'demo';
		public var sub_key:String = 'demo';
		public var origin:String = 'pubsub.pubnub.com';
        public var secret_key:String = '';
        public var cipher_key:String = '';
		public var ssl:Boolean = false;

		private var channel:String;
		private var _isRun:Boolean;
		
		private var sent:Number = 0;
		private var message:String = '1';
		private var startPublishTime:int;
		private var latencyAvg:Number = 0;
		private var median:Array
		private var medlen:Number;
		private var updateInterval:int;
		private var view:DisplayObjectContainer;
		private const MAX_LATENCY:Number = 1000;
		
		public function Perfomance(view:DisplayObject) {
			super();
			this.view = view as DisplayObjectContainer;
		}
		
		public function start():void {
			_isRun = true;
			channel = 'performance-meter-' + getTimer() + Math.random();
			sent = 0;
			latencyAvg = 0;
			clearInterval(updateInterval);
			median = [0];
			updateMedians();
			Pn.instance.addEventListener(PnEvent.INIT, onPnInit);
			Pn.instance.addEventListener(PnEvent.SUBSCRIBE, onPnSubscribe);
			Pn.init( { 
				origin:			this.origin,
                publish_key:	this.pub_key,
                sub_key:		this.sub_key,
                secret_key:		this.secret_key,
                cipher_key:		this.cipher_key,
                ssl:			this.ssl } );
		}
		
		public function stop():void {
			clearInterval(updateInterval);
			_isRun = false;
			latencyAvg = 0;
			sent = 0;
			update();
			Pn.instance.unsubscribe(channel);
			Pn.instance.removeEventListener(PnEvent.INIT, onPnInit);
			Pn.instance.removeEventListener(PnEvent.SUBSCRIBE, onPnSubscribe);
		}
		
		public function get isRun():Boolean {
			return _isRun;
		}
		
		private function onPnInit(e:PnEvent):void {
			Pn.subscribe(channel);	
		}
		
		private function onPnSubscribe(e:PnEvent):void {
			 switch (e.status) {
                case OperationStatus.DATA:
					if (e.channel == channel && 
						e.data.result[1] == message) {
						sent++;
						var delta:Number  = getTimer() - startPublishTime;
						var latency:Number = delta || median[1];
						latencyAvg = Math.floor((latency + latencyAvg) / 2);
						median.push(latency);
						update();
						publish();
					}
                    break;

                case OperationStatus.CONNECT:
					clearInterval(updateInterval);
					updateInterval = setInterval(update, 500);
					publish();
                    break;
					
                case OperationStatus.ERROR:
					trace('subscribe error');
                    break;
            }
		}
		
		private function  updateMedians():void {
			var length:Number = median.length - 1;
			medlen = Math.floor(length / 2);
			median.sort(Array.NUMERIC);
		}
		
		private function getMedian(val:Number) :Number {
			var length:int = median.length - 1;
			return median[medlen + Math.floor(length * val)];
		}
		
		private function getMedianLow(val:Number):Number {
			var length:int = median.length - 1;
			return median[Math.floor(medlen * val) || 1];
		}
		
		private function publish():void {
			startPublishTime = getTimer();
			Pn.publish( { 
				channel : channel, 
				message : message } );
		}
		
		private function update():void {
			//trace('update');
			updateMedians();
			if (view) {
				// animate arrow
				try {
					var arrow:DisplayObject = view['arrow'];
					//arrow.rotation = angle;
				}catch (err:Error){
					// no arrow in the view
				}
				if (arrow) {
					var l:Number = latencyAvg > MAX_LATENCY ? MAX_LATENCY : latencyAvg;
					var a:Number =  180 * l / MAX_LATENCY;
					TweenMax.killTweensOf(arrow);
					TweenMax.to(arrow, 0.6, {rotation : a, ease:Linear.easeNone})
				}
				
				// average latency
				try {
					var averageLatencyTxt:TextField = view['averageLatencyTxt'];
					averageLatencyTxt.text = latencyAvg + '\nms';
				}catch (err:Error) { }
				
				// stats
				try {
					var totalSamplesTxt:TextField = view['totalSamplesTxt'];
					totalSamplesTxt.text = sent + ' Performance Samples Recorded';
				}catch (err:Error) { }
				
				try {
					view['txt_fastest'].text =  getMedianLow(0.02);
					view['txt_5'].text = getMedianLow(0.05);
					view['txt_10'].text = getMedianLow(0.1);
					view['txt_20'].text = getMedianLow(0.2);
					view['txt_25'].text = getMedianLow(0.5);
					view['txt_30'].text = getMedianLow(0.6);
					view['txt_40'].text = getMedianLow(0.8);
					view['txt_45'].text = getMedianLow(0.9);
					view['txt_50'].text = median[medlen];
					view['txt_66'].text = getMedian(0.16);
					view['txt_75'].text = getMedian(0.25);
					view['txt_80'].text = getMedian(0.30);
					view['txt_90'].text = getMedian(0.40);
					view['txt_95'].text = getMedian(0.45);
					view['txt_98'].text = getMedian(0.48);
					view['txt_slowest'].text = median[median.length - 1];
					
					view['txt2_fastest'].text = view['txt_fastest'].text;
					view['txt2_5'].text = view['txt_5'].text;
					view['txt2_10'].text = view['txt_10'].text;
					view['txt2_20'].text = view['txt_20'].text;
					view['txt2_25'].text = view['txt_25'].text;
					view['txt2_30'].text = view['txt_30'].text;
					view['txt2_40'].text = view['txt_40'].text;
					view['txt2_45'].text = view['txt_45'].text;
					view['txt2_50'].text = view['txt_50'].text;
					view['txt2_66'].text = view['txt_66'].text;
					view['txt2_75'].text = view['txt_75'].text;
					view['txt2_80'].text = view['txt_80'].text;
					view['txt2_90'].text = view['txt_90'].text;
					view['txt2_95'].text = view['txt_95'].text;
					view['txt2_98'].text = view['txt_98'].text;
					view['txt2_slowest'].text = view['txt_slowest'].text;
					
				}catch (err:Error){
					
				}
			}
		}
		
		
	}
}