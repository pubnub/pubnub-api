package com.pubnub {
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Settings {
		
		public static const MAX_FORCE_RECONNECT_RETRIES:uint = 100;
		
		// milliseconds
		public static const FORCE_RECONNECT_DELAY:uint = 1000;

		// milliseconds
		public static const RECONNECT_DELAY:uint = 15000;
		
		// millseconds
		public static const OPERATION_TIMEOUT:uint = 310000;
		
		// resume to subscribe channel with last timetoken
		public static const RESUME_ON_RECONNECT:Boolean = true;
	}
}