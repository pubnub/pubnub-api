package com.pubnub.operation {
	import com.pubnub.net.URLRequest;
	import com.pubnub.Settings;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class TimeOperation extends Operation {
		
		public function TimeOperation (origin:String, timeout:int = 0) {
			super(origin);
			if (timeout > 0 && timeout < Settings.OPERATION_TIMEOUT) {
				_timeout = timeout;
			}
		}
		
		override public function setURL(url:String = null, args:Object = null):URLRequest {
			url = origin + '/time/0';
			return super.setURL(url, args);
		}
	}
}