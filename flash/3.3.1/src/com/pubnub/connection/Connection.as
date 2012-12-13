package com.pubnub.connection {
	import com.pubnub.loader.*;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Connection {
		protected var loader:URLLoader;
		protected var _destroyed:Boolean;
		protected var queue:/*Operation*/Array;
		protected var operation:Operation;
		protected var _closed:Boolean;
		
		public function Connection() {
			init();
		}
		
		protected function init():void {
			queue = [];
			loader = new URLLoader();
			loader.addEventListener(URLLoaderEvent.COMPLETE, 	onComplete)
			loader.addEventListener(URLLoaderEvent.ERROR, 		onError);
			loader.addEventListener(Event.CONNECT, 				onConnect);
			loader.addEventListener(Event.CLOSE, 				onClose);
		}
		
		protected function onClose(e:Event):void {
			
		}
		
		protected function get ready():Boolean{
			return loader && loader.ready && queue && queue.length == 0;
		}
		
		protected function onConnect(e:Event):void {
			// abstract
			_closed = false;
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
			
		}
		
		public function getLastOperation():Operation{
			return operation;
		}
		
		public function destroy():void {
			if (_destroyed) return;
			loader.removeEventListener(URLLoaderEvent.COMPLETE, onComplete)
			loader.removeEventListener(URLLoaderEvent.ERROR, 	onError);
			loader.removeEventListener(Event.CONNECT, 			onConnect);
			loader.removeEventListener(Event.CLOSE, 			onClose);
			close();
			loader.destroy();
			loader = null;
			
			_destroyed = true;
			queue = null;
			operation = null;
		}
		
		public function close():void {
			_closed = true;
			queue.length = 0;
			operation = null;
			loader.close();
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}