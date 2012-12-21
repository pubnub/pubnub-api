package com.pubnub.connection {
	import com.pubnub.Errors;
	import com.pubnub.log.Log;
	import com.pubnub.net.URLLoaderEvent;
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class HeartBeatConnection extends Connection {
		private var timeoutInterval:int;
		
		public function HeartBeatConnection() {
			super();
		}
		
		override public function sendOperation(operation:Operation):void {
			super.sendOperation(operation);
			var timeout:int = operation.timeout || 10000;
			trace('doSendOperation : ' + timeout, operation.url);
			clearTimeout(timeoutInterval);
			timeoutInterval = setTimeout(onTimeout, operation.timeout, operation);
			this.operation = operation;
			if (loader.connected) {
				loader.load(operation.request);
				this.operation.startTime = getTimer();
			}else {
				loader.connect(operation.request);
			}	
		}
		
		private function onTimeout(operation:Operation):void {
			trace(this, 'onTimeout');
			if (operation) {
				Log.logTimeout(Errors.OPERATION_TIMEOUT + ', ' + operation.request.url);
				operation.onError( { message:Errors.OPERATION_TIMEOUT, operation:operation } );
			}
		}
		
		private function removeOperation(operation:Operation):void {
			var ind:int = queue.indexOf(operation);
			if (ind > -1) {
				queue.splice(ind, 1);
			}
		}
		
		override protected function onComplete(e:URLLoaderEvent):void {
			trace('onComplete : ' + operation);
			super.onComplete(e);
			operation = null;
		}
		
		override protected function onConnect(e:Event):void {
			trace('onConnect : ' + operation);
			super.onConnect(e);
			if (operation) {
				sendOperation(operation);
			}
		}	
	}
}