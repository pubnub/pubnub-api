package com.pubnub.operation {
	import com.pubnub.net.URLRequest;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class TimeOperation extends Operation {
		
		public function TimeOperation (origin:String) {
			super(origin);
		}
		
		override public function setURL(url:String = null, args:Object = null):URLRequest {
			url = origin + '/time/0';
			return super.setURL(url, args);
		}
	}

}