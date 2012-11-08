package com.pubnub.loader {
	import com.adobe.net.*;
	import flash.events.*;
	import org.httpclient.*;
	import org.httpclient.events.*;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[Event(name="PnURLLoaderEvent.error", type="com.pubnub.loader.PnURLLoaderEvent")]
	[Event(name="PnURLLoaderEvent.complete", type="com.pubnub.loader.PnURLLoaderEvent")]
	public class PnURLLoader extends EventDispatcher {
		
		private var _destroyed:Boolean;
		public var httpClient:HttpClient;
		private var listener:HttpListener;
		private var _url:String;
		private var timeout:Number;
		
		
		public function PnURLLoader(timeout:Number = 310000) {
			super(null);
			this.timeout = timeout;
			init();
		}	
		
		private function init():void {
			var uri:URI = new URI(_url);
			httpClient = new HttpClient(null, timeout);
			listener = new HttpListener();
			listener.addEventListener(HttpDataEvent.DATA, onHttpData);
			listener.addEventListener(HttpErrorEvent.ERROR, onHttpDataError);
			listener.addEventListener(HttpErrorEvent.TIMEOUT_ERROR, onHttpDataError);
		}
		
		public function load(url:String):void {
			this._url = url;
			//var uri:URI = new URI(url);
			//trace('uri.scheme : ' + uri.scheme);
			//trace('uri.scheme : ' + uri.);
			httpClient.get(new URI(url), listener);
		}
		
		private function onHttpDataError(e:HttpErrorEvent):void {
			dispatchEvent(new PnURLLoaderEvent(PnURLLoaderEvent.ERROR, {message:e.text, id:e.errorID}));
		}
		
		private function onHttpData(e:HttpDataEvent):void {
			dispatchEvent(new PnURLLoaderEvent(PnURLLoaderEvent.COMPLETE, e.readUTFBytes()));
		}
		
		public function destroy():void {
			if (_destroyed) return;
			_destroyed = true;
			close();
			listener.removeEventListener(HttpDataEvent.DATA, onHttpData);
			listener.removeEventListener(HttpErrorEvent.ERROR, onHttpDataError);
			listener.removeEventListener(HttpErrorEvent.TIMEOUT_ERROR, onHttpDataError);
			listener.unregister();
			listener = null;
			httpClient = null;
		}
		
		public function close():void {
			httpClient.close();
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
		
		public function get url():String {
			return _url;
		}
	}
}