package com.pubnub.net {
	import com.pubnub.operation.Operation;
	import com.pubnub.Settings;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Connection {
		
		static private var __instance:Connection;
		private var syncLoader:SyncURLLoader;
		private var asyncLoader:AsyncURLLoader;
		private var asyncOperation:Operation;
		private var syncOperations:Vector.<Operation>;
		
		public function Connection() {
			if (__instance) throw ('Use [Connection.instance] getter');
			setup();
		}
		
		public static  function get instance():Connection {
			__instance ||= new Connection();
			return __instance;
		}
		
		private function setup():void {
			syncLoader = new SyncURLLoader(Settings.SYNC_CHANNEL_TIMEOUT);
			syncLoader.addEventListener(URLLoaderEvent.COMPLETE, onSyncLoaderComplete)
			syncLoader.addEventListener(URLLoaderEvent.ERROR, onSyncLoaderError);
			
			asyncLoader = new AsyncURLLoader();
			asyncLoader.addEventListener(URLLoaderEvent.COMPLETE, onLoaderComplete);
			asyncLoader.addEventListener(URLLoaderEvent.ERROR, onLoaderError);
			syncOperations = new Vector.<Operation>;
		}
		
		public static function closeSyncChannel():void {
			instance.syncOperations.length = 0;
			instance.syncLoader.close();
		}
		
		public static function closeAsyncChannel():void {
			instance.asyncLoader.close();
		}
		
		public static function close():void {
			closeSyncChannel();
			closeAsyncChannel();
		}
		
		public static function sendAsync(operation:Operation):void {
			instance.sendAsyncOperation(operation);
		}
		
		private function sendAsyncOperation(operation:Operation):void {
			asyncOperation = operation;
			asyncLoader.load(operation.request);
		}
		
		public static function sendSync(operation:Operation):void {
			instance.sendSyncOperation(operation);
		}
		
		public static function removeSyncOperations(vector:Vector.<Operation>):void {
			if (vector && vector.length) {
				var temp:Vector.<Operation> = new Vector.<Operation>;
				for each(var intern:Operation  in instance.syncOperations) {
					var uniq:Boolean = true;
					for each(var extern:Operation  in vector) {
						if (intern == extern) {
							uniq = false;
							break;
						}
					}
					if (uniq) {
						temp.push(intern);
					}
				}
				instance.syncOperations = temp;
			}
		}
		
		private function sendSyncOperation(operation:Operation):void {
			//trace('sendSyncOperation : ' + operation.url);
			syncOperations.push(operation);
			syncLoader.load(operation.request);
		}
		
		private function onSyncLoaderComplete(e:URLLoaderEvent):void {
			var response:URLResponse = e.data as URLResponse;
			var op:Operation = popSyncOperation(e.data.request);
			//trace('onSyncLoaderComplete : ' + op, syncOperations.length, response.body);
			if (op) {
				op.onData(response.body);
			}
			
		}
		
		private function popSyncOperation(request:URLRequest):Operation {
			var result:Operation;
			for each(var i:Operation  in syncOperations) {
				if (i.request == request) {
					result = i;
					// remove from vector
					syncOperations.splice(syncOperations.indexOf(i), 1);
					break;
				}
			}
			return result;
		}
		
		private function onSyncLoaderError(e:URLLoaderEvent):void {
			var response:URLResponse = e.data as URLResponse;
			var op:Operation = popSyncOperation(e.data.request);
			if (op) {
				op.onError(response.body);
			}
		}
		
		private function onLoaderComplete(e:URLLoaderEvent):void {
			//trace('onLoaderComplete');
			var response:URLResponse = e.data as URLResponse;
			if (asyncOperation) {
				asyncOperation.onData(response.body);
			}
		}
		
		private function onLoaderError(e:URLLoaderEvent):void {
			var response:URLResponse = e.data as URLResponse;
			if (asyncOperation) {
				asyncOperation.onError(response.body);
			}
		}
	}
}