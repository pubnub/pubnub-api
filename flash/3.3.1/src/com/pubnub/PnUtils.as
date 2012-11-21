package com.pubnub {
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class PnUtils {
		private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
		public static function getUID():String {
			var temp:Array = new Array(36);
			var index:int = 0;
			
			var i:int;
			var j:int;
			
			for (i = 0; i < 8; i++){
				temp[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			
			for (i = 0; i < 3; i++){
				temp[index++] = 45; // charCode for "-"
				for (j = 0; j < 4; j++){
					temp[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
				}
			}
			
			temp[index++] = 45; // charCode for "-"
			
			for (i = 0; i < 8; i++){
				temp[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			
			for (j = 0; j < 4; j++){
				temp[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			
			var time:Number = new Date().getTime();
			// Note: time is the number of milliseconds since 1970,
			// which is currently more than one trillion.
			// We use the low 8 hex digits of this number in the UID.
			// Just in case the system clock has been reset to
			// Jan 1-4, 1970 (in which case this number could have only
			// 1-7 hex digits), we pad on the left with 7 zeros
			// before taking the low digits.
			
			return String.fromCharCode.apply(null, temp);
		}
		
		/**
		 * Encodes a string into some format
		 * Should be the escape function
		 * @param       args
		 * @return
		 */
		public static function encode(args:String):String{
			return escape(args);
		}
	}

}