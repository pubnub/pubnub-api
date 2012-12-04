package com.pubnub.net {
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class AsyncConnection extends ConnectionBase {
		
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
			super.onConnect(e);
			trace('onConnect: ' + queue.length, ready);
			//return;
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
			this.operation = operation;
			loader.load(operation.request);
		}
	}
}