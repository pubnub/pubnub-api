package com.pubnub.connection {
	import com.pubnub.*;
	import com.pubnub.log.*;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class SyncConnection extends Connection {
		
		protected var _timeout:int = 310000;
		protected var timeoutInterval:int;
		protected var pendingConnection:Boolean;
		protected var initialized:Boolean
		private var busy:Boolean;
		
		public function SyncConnection(timeout:int = 310000) {
			super();
			_timeout = timeout;
		}
		
		override public function sendOperation(operation:Operation):void {
			if (!operation) return;
			//trace('sendOperation : ' + ready, operation);
			if (ready) {
				doSendOperation(operation);
			}else {
				if (loader.connected == false) {
					loader.connect(operation.request);
				}
			}
			
			if (queue.indexOf(operation) == -1) {
				queue.push(operation);
			}
		}
		
		private function doSendOperation(operation:Operation):void {
			//trace('doSendOperation : ' + busy, operation.destroyed);
			clearTimeout(timeoutInterval);
			timeoutInterval = setTimeout(onTimeout, _timeout, operation);
			busy = true;
			this.operation = operation;
			loader.load(operation.request);
		}
		
		private function onTimeout(operation:Operation):void {
			if (operation) {
				logTimeoutError(operation);
				Log.logTimeout(Errors.OPERATION_TIMEOUT + ', ' + operation.request.url);
				operation.onError( { message:Errors.OPERATION_TIMEOUT, operation:operation } );
				removeOperation(operation);
			}
			this.operation = null;
			busy = false;
			operation = null;
			sendNextOperation();
		}
		
		private function removeOperation(operation:Operation):void {
			var ind:int = queue.indexOf(operation);
			if (ind > -1) {
				queue.splice(ind, 1);
			}
		}
		
		private function logTimeoutError(operation:Operation):void {
			var args:Array = [Errors.OPERATION_TIMEOUT];
			var op:Operation = getLastOperation();
			if (op) {
				args.push(op.url);
			}
			Log.log(args.join(','), Log.ERROR, Errors.OPERATION_TIMEOUT);
		}
		
		private function sendNextOperation():void {
			if (queue.length > 0) {
				doSendOperation(queue.shift());
			}
		}
		
		override public function close():void {
			for each(var o:Operation  in queue) {
				o.destroy();
			}
			super.close();
			busy = false;
			initialized = false;
			clearTimeout(timeoutInterval);
		}
		
		public function reconnect():void {
			//trace(this, 'reconnect');
			busy = false;
			sendOperation(queue[0]);
		}
		
		override protected function onConnect(e:Event):void {
			//trace('onConnect : ' + queue[0]);
			super.onConnect(e);
			doSendOperation(queue[0]);
		}
		
		override protected function get ready():Boolean {
			return super.ready && !busy;
		}
		
		override protected function onComplete(e:URLLoaderEvent):void {
			//trace('onComplete : ' + operation);
			clearTimeout(timeoutInterval);
			removeOperation(operation);
			super.onComplete(e);
			busy = false;
			operation = null;
			sendNextOperation();
		}
	}
}