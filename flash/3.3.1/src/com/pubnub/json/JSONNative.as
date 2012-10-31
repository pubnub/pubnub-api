package com.pubnub.json {
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class JSONNative {
		
		static public function parse(text:String, reviver:Function = null):Object {
			return JSON.parse(text, reviver);
		}
		
		static public  function stringify(value:Object, replacer:* = null, space:* = null):String {
			return JSON.stringify(value, replacer, space);
		}	
	}
}