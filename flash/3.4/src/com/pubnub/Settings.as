package com.pubnub {
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Settings {
        // retry to connect a maximum of this many times before Pn.shutdown()
		public static const MAX_RECONNECT_RETRIES:uint = 30; //100;

        // if true, after reconnecting (after detecting disconnect), 'catches up' on missed messages upon reconnect
        public static const RESUME_ON_RECONNECT:Boolean = true;

        // Given the above defaults
        // the client would check for 5 minutes (300s) after network loss
        // ie, 100 times, every 3 seconds for a network connection
		
		// time in millseconds to wait for web server to return a response. DO NOT CHANGE unless requested by support
		public static const OPERATION_TIMEOUT:uint = 10000;
				
		// for wait a response of a ping operation with [PING_OPERATION_URL], ms 
		public static const PING_OPERATION_TIMEOUT:uint = 2000;
		
		// check for network down every [PING_OPERATION_INTERVAL],ms.
		public static const PING_OPERATION_INTERVAL:uint = 5000;
		
		// chck a network status uses URL
		public static const PING_OPERATION_URL:String = 'http://pubsub.pubnub.com/time/0';
	}
}