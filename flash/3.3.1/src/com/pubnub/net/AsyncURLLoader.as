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
		
		public function AsyncURLLoader () {
			super();
		}
		
		override public function load(request:URLRequest):void {
			super.load(request);
			sendRequest(request);
		}
	}
}