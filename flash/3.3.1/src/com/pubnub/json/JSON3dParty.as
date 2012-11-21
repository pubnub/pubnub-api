package com.pubnub.json {
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class JSON3dParty {
		
		import com.adobe.serialization.json.JSON;
		
		static public function parse(text:String, reviver:Function = null):Object {
			return com.adobe.serialization.json.JSON.decode(text);
		}
		
		static public  function stringify(value:Object, replacer:* = null, space:* = null):String {
			return com.adobe.serialization.json.JSON.encode(value);
		}
	}
}