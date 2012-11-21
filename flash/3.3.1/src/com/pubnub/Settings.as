package com.pubnub {
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class Settings {

        //
        // Reconnection Settings
        //

        // retry to connect a maximum of this many times before unsubscribing from channel.
		public static const MAX_RECONNECT_RETRIES:uint = 100;

        // after disconnect is detected, and network ping for connection detection begins again,
        // millisecond timeout to determine if Pubnub ping ( time() ) connects
        // default is 1000ms - this means that it will wait up to 1s to see if the time() heartbeat connects.
		public static const RECONNECT_HEARTBEAT_TIMEOUT:uint = 3000;

        // if true, after reconnecting (after detecting disconnect), 'catches up' on missed messages upon reconnect
        public static const RESUME_ON_RECONNECT:Boolean = true;

        // Given the above defaults
        // the client would check for 5 minutes (300s) after network loss
        // ie, 100 times, every 3 seconds for a network connection


		// while connected in subscribe mode, check for network down every 15s.
		public static const CONNECTION_HEARTBEAT_INTERVAL:uint = 15000;
		
		// time in millseconds to wait for web server to return a response. DO NOT CHANGE unless requested by support
		public static const OPERATION_TIMEOUT:uint = 310000;
		

	}
}