package com.pubnub.net {
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class SyncConnection extends ConnectionBase {
		
		override public function sendOperation(operation:Operation):void {
			super.sendOperation(operation);
			if (ready) {
				doSendOperation(operation);
			}else {
				loader.connect(operation.request);
				queue.push(operation);
			}
		}
		
		private function doSendOperation(operation:Operation):void {
			this.operation = operation;
			loader.load(operation.request);
		}
		
		private function sendNextOperation():void {
			if (queue.length > 0) {
				doSendOperation(queue.pop());
			}
		}
		
		override protected function onConnect(e:Event):void {
			super.onConnect(e);
			sendNextOperation();
		}
		
		override protected function onComplete(e:URLLoaderEvent):void {
			super.onComplete(e);
			sendNextOperation();
		}
	}
}