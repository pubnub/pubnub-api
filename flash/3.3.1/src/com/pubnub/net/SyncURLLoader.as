package com.pubnub.net {
	import com.adobe.net.*;
	import com.pubnub.Errors;
	import flash.events.*;
	import flash.net.Socket;
	import flash.net.URLRequestMethod;
	import flash.utils.*;
	
	/**
	 * Sync URLLoader (with queue)
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[Event(name="URLLoaderEvent.complete", type="com.pubnub.net.URLLoaderEvent")]
	[Event(name="URLLoaderEvent.error", type="com.pubnub.net.URLLoaderEvent")]
	public class SyncURLLoader extends URLLoaderBase {
		
		private var timeout:int;
		private var syncTimer:int;
		private var queue:Array;
		
		public function SyncURLLoader(timeout:int = 5000) {
			super();
			this.timeout = timeout;
		}
		
		override protected function init():void {
			super.init();
			queue = [];
		}
		
		override public function load(request:URLRequest):void {
			if (!request) return;
			super.load(request);
			if (ready == false) {
				queue.push(request);
			}
			sendRequest(request);
		}
		
		override protected function onConnect(e:Event):void {
			//trace('onConnect');
			request = queue.pop();
			sendRequest(request);
		}
		
		override protected function sendRequest(request:URLRequest):void {
			clearTimeout(syncTimer);
			syncTimer = setTimeout(onSyncTimeout, timeout);
			super.sendRequest(request);
		}
		
		private function onSyncTimeout():void {
			// break last request
			dispatchEvent(new  URLLoaderEvent(URLLoaderEvent.ERROR, request));
			sendNextRequest();
		}
		
		private function sendNextRequest():void {
			if (queue.length > 0) {
				sendRequest(queue.pop());
			}
		}
		
		override protected function onResponce(bytes:ByteArray):void {
			//trace('onResponce');
			super.onResponce(bytes);
			clearTimeout(syncTimer);
			sendNextRequest();
		}
		
		override public function close():void {
			super.close();
			clearTimeout(syncTimer);
			queue.length = 0;
		}
		
		override public function destroy():void {
			if (_destroyed) return;
			super.destroy();
			queue = null;
			clearTimeout(syncTimer);
		}
	}
}