package com.pubnub.net {
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Connection {
		
		static private var __instance:Connection;
		private var loaderKA:URLLoader;
		private var loader:URLLoader;
		private var queue:Array;
		private var queueKA:Array;
		private var lastOperation:Operation;
		
		public function Connection() {
			if (__instance) throw ('Use [Connection.instance] getter');
			setup();
		}
		
		public static  function get instance():Connection {
			__instance ||= new Connection();
			return __instance;
		}
		
		private function setup():void {
			loaderKA = new URLLoader();
			loaderKA.keepAlive = true;
			loaderKA.addEventListener(Event.COMPLETE, onKALoaderComplete);
			loaderKA.addEventListener(IOErrorEvent.IO_ERROR, onKALoaderError);
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			
			queue = [];
			queueKA = [];
		}
		
		public static function load(operation:Operation):void {
			instance.load(operation);
		}
		
		public function load(operation:Operation):void {
			queue.push(operation);
			if (queue.length == 1) {
				send(operation);
			}
		}
		
		private function send(operation:Operation):void {
			loader.load(operation.url);
		}
		
		public static function loadWithKeepAlive(operation:Operation):void {
			instance.loadWithKeepAlive(operation);
		}
		
		public function loadWithKeepAlive(operation:Operation):void {
			
			trace('loadWithKeepAlive : ' + queueKA.length, isSubscriptionOperation(lastOperation));
			queueKA.push(operation);
			if (queueKA.length == 1 || isSubscriptionOperation(lastOperation)) {
				sendKA(operation);
			}
			this.lastOperation = operation;
		}
		
		private function sendKA(operation:Operation):void {
			//trace('sendKA : ' + operation.url);
			lastOperation = operation;
			loaderKA.load(operation.url);
		}
		
		private function isSubscriptionOperation(operation:Operation):Boolean {
			if (!operation) return false;
			trace(operation.url);
			return (operation.url.indexOf('subscribe') > -1);
		}
		
		private function onKALoaderComplete(e:Event):void {
			var data:Object = e.target.data;
			var operation:Operation = queueKA.pop();
			if (queueKA.length > 0) {
				sendKA(queueKA[0]);
			}
			//this.operation.onData(data);
			operation.onData(data);
			
			//trace('onKALoaderComplete : ' + queueKA.length);
		}
		
		private function onKALoaderError(e:IOErrorEvent):void {
			//trace('onKALoaderError : ' + queueKA.length);
			var operation:Operation = queueKA.pop();
			operation.onError(e.target.data);
			if (queueKA.length > 0) {
				sendKA(queueKA[0]);
			}
		}
		
		private function onLoaderComplete(e:Event):void {
			
			var operation:Operation = queue.pop();
			operation.onData(e.target.data);
			//trace(this, 'onLoaderComplete : ' + queue.length, queue[0]);
			if (queue.length > 0) {
				send(queue[0]);
			}
		}
		
		private function onLoaderError(e:IOErrorEvent):void {
			var operation:Operation = queue.pop();
			operation.onError(e.target.data);
			if (queue.length > 0) {
				send(queue[0]);
			}
		}
	}
}