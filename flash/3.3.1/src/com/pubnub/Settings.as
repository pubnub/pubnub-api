package com.pubnub {
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Settings {
        // retry to connect a maximum of this many times before un-subscribing from channel.
		public static const MAX_RECONNECT_RETRIES:uint = 5; //100;

        // if true, after reconnecting (after detecting disconnect), 'catches up' on missed messages upon reconnect
        public static const RESUME_ON_RECONNECT:Boolean = true;

        // Given the above defaults
        // the client would check for 5 minutes (300s) after network loss
        // ie, 100 times, every 3 seconds for a network connection
		
		// time in millseconds to wait for web server to return a response. DO NOT CHANGE unless requested by support
		public static const OPERATION_TIMEOUT:uint = 310000;
		
		// for wait a response of a ping operation in HeartBeatConnection, ms 
		public static const PING_OPEARTION_TIMEOUT:uint = 5000;
		
		// check for network down every [PING_OPERATION_INTERVAL],ms.
		public static const PING_OPERATION_INTERVAL:uint = 1000; // 15000;
	}
}