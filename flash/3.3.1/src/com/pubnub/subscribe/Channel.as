package com.pubnub.subscribe {
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Channel {
		public var name:String;
		public var uid:String;
		
		public function Channel(uid:String = null, name:String = null) {
			this.name = name;
			this.uid = uid;
		}
	}
}