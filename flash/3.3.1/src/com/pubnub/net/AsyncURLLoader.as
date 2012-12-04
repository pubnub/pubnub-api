package com.pubnub.net {
	import com.adobe.net.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.net.URLRequestMethod;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[Event(name="URLLoaderEvent.complete", type="com.pubnub.net.URLLoaderEvent")]
	[Event(name="URLLoaderEvent.error", type="com.pubnub.net.URLLoaderEvent")]
	public class AsyncURLLoader extends URLLoaderBase {
		
		private var queue:Array;
		
		override protected function init():void {
			super.init();
			queue = [];
		}
		
		override public function load(request:URLRequest):void {
			//trace('load : ' + request.url);
			super.load(request);
			sendRequest(request);
		}
		
		override protected function sendRequest(request:URLRequest):void {
			if (ready) {
				doSendRequest(request);
			}else {
				connect(request);
				queue.push(request);
			}
		}
		
		override protected function onConnect(e:Event):void {
			if (queue.length > 0) {
				var r:URLRequest = queue.pop();
				sendRequest(request);
			}
		}
		
		override protected function doSendRequest(request:URLRequest):void {
			super.doSendRequest(request);
			if (queue.length > 0) {
				var r:URLRequest = queue.pop();
				sendRequest(request);
			}
		}
	}
}