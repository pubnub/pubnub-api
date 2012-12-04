package com.pubnub.net {
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class ConnectionBase {
		
		protected var loader:URLLoaderBase;
		protected var _destroyed:Boolean;
		protected var queue:/*Operation*/Array;
		protected var operation:Operation;
		
		public function ConnectionBase() {
			init();
		}
		
		protected function init():void {
			queue = [];
			loader = new URLLoaderBase();
			loader.addEventListener(URLLoaderEvent.COMPLETE, onComplete)
			loader.addEventListener(URLLoaderEvent.ERROR, onError);
			loader.addEventListener(Event.CONNECT, onConnect);
		}
		
		protected function get ready():Boolean{
			return loader.ready && queue && queue.length == 0;
		}
		
		
		protected function onConnect(e:Event):void {
			// abstract
		}
		
		protected function onError(e:URLLoaderEvent):void {
			// abstract
		}
		
		protected function onComplete(e:URLLoaderEvent):void {
			var response:URLResponse = e.data as URLResponse;
			if (operation) {
				operation.onData(response.body);
			}
		}
		
		public function sendOperation(operation:Operation):void {
			// abstract
		}
		
		public function cancelOperation(operation:Operation):void {
			operation = null;
		}
		
		public function destroy():void {
			if (_destroyed) return;
			loader.removeEventListener(URLLoaderEvent.COMPLETE, onComplete)
			loader.removeEventListener(URLLoaderEvent.ERROR, onError);
			dispose();
			loader = null;
			_destroyed = true;
			queue = null;
			operation = null;
		}
		
		public function dispose():void {
			queue.length = 0;
			loader.close();
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}