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
			loader.keepAlive = true;
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
			if (loader.connectPending) {
				// wait....
			}else {
				loader.load(operation.url);
			}
			
		}
		
		public static function loadWithKeepAlive(operation:Operation):void {
			instance.loadWithKeepAlive(operation);
		}
		
		public function loadWithKeepAlive(operation:Operation):void {
			//trace('loadWithKeepAlive : ' + queueKA.length, isSubscriptionOperation(lastOperation));
			sendKA(operation);
		}
		
		private function sendKA(operation:Operation):void {
			//trace('sendKA : ' + operation.url);
			lastOperation = operation;
			loaderKA.load(operation.url);
		}
		
		private function onKALoaderComplete(e:Event):void {
			trace('onKALoaderComplete : ' + lastOperation.url);
			var data:Object = e.target.data;
			lastOperation.onData(data);
		}
		
		private function onKALoaderError(e:IOErrorEvent):void {
			trace('onKALoaderError : ' + lastOperation);
			lastOperation.onError(e.target.data);
			//lastOperation = null;
		}
		
		private function onLoaderComplete(e:Event):void {
			var operation:Operation = queue.pop();
			trace('onLoaderComplete : ' + operation);
			if(operation) operation.onData(e.target.data);
			if (queue.length > 0) {
				send(queue[0]);
			}
		}
		
		private function onLoaderError(e:IOErrorEvent):void {
			var operation:Operation = queue.pop();
			trace('onLoaderError : ' + operation);
			if(operation) operation.onError(e.target.data);
			if (queue.length > 0) {
				send(queue[0]);
			}
		}
	}
}