package com.pubnub.connection {
	import com.pubnub.net.URLLoader;
	import com.pubnub.net.URLLoaderEvent;
	import com.pubnub.net.URLResponse;
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Connection {
		
		protected var loader:URLLoader;
		protected var _destroyed:Boolean;
		protected var queue:/*Operation*/Array;
		protected var operation:Operation;
		
		public function Connection() {
			init();
		}
		
		protected function init():void {
			queue = [];
			loader = new URLLoader();
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
			if (operation && !operation.destroyed) {
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
			close();
			loader = null;
			_destroyed = true;
			queue = null;
			operation = null;
		}
		
		public function close():void {
			queue.length = 0;
			loader.close();
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}