package com.pubnub.connection {
	import com.pubnub.net.URLLoaderEvent;
	import com.pubnub.operation.Operation;
	import com.pubnub.operation.OperationEvent;
	import com.pubnub.Settings;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class AsyncConnection extends Connection {
		
		protected var timeout:int;
		
		override protected function init():void {
			super.init();
		}
		
		override public function sendOperation(operation:Operation):void {
			super.sendOperation(operation);
			if (ready) {
				doSendOperation(operation);
			}else {
				loader.connect(operation.request);
				queue.push(operation);
			}
		}
		
		override protected function onConnect(e:Event):void {
			if (queue.length > 0) {
				for (var i:int = 0; i < queue.length; i++) {
					sendOperation(queue[i]);
				}
				queue.length = 0;
			}
		}
		
		override protected function get ready():Boolean {
			return loader.ready;
		}
		
		private function doSendOperation(operation:Operation):void {
			clearTimeout(timeout);
			timeout = setTimeout(onTimeout, Settings.OPERATION_TIMEOUT, operation);
			this.operation = operation;
			loader.load(operation.request);
		}
		
		private function onTimeout(operation:Operation):void {
			dispatchEvent(new OperationEvent(OperationEvent.TIMEOUT, operation));
		}
		
		override public function close():void {
			clearTimeout(timeout);
			super.close();
		}
		
		override protected function onError(e:URLLoaderEvent):void {
			clearTimeout(timeout);
			super.onError(e);
		}
		
		override protected function onClose(e:Event):void {
			clearTimeout(timeout);
			super.onClose(e);
		}
	}
}