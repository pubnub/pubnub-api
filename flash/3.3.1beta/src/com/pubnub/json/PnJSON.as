package com.pubnub.json {
	/**
	 * Note: here uses univeral solution for fp 10- versions
	 * try/catch consruction is more slow! 
	 * you can choose native or 3d party JSON libs for optimization.
	 * 
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class PnJSON {
		
		//import com.adobe.serialization.json.JSON;
		
		
		static public function parse(text:String, reviver:Function = null):Object {
			try {
				
				return JSONNative.parse(text, reviver);
			}catch (err:Error) {
				// native JSON works with error here
			}
			return JSON3dParty.parse(text);
		}
		
		static public  function stringify(value:Object, replacer:* = null, space:* = null):String {
			try {
				return JSONNative.stringify(value, replacer, space);
			}catch (err:Error) {
				// native JSON works with error here
			}
			
			return JSON3dParty.stringify(value);
		}
	}
}