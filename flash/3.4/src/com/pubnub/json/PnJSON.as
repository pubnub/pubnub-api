package com.pubnub.json {
import com.pubnub.log.Log;

/**
	 * Note: here uses univeral solution for fp 10- versions
	 * try/catch consruction is more slow! 
	 * you can choose native or 3d party JSON libs for optimization.
	 * 
	 * @author firsoff maxim, support@pubnub.com
	 */

public class PnJSON {

    //static var ticker:int;

    static public function parse(text:String, reviver:Function = null):Object {
        //ticker ||= 0;
        //ticker++;

        //Log.log(ticker.toString(), Log.DEBUG);

        /// Debug blowup

//        if (ticker == 5) {
//            Log.log("**** PNJSON SPLAT!****", Log.DEBUG);
//            trace(new Date() + "**** PnJSON SPLAT!****", Log.DEBUG);
//            var badParse:Object = JSON3dParty.parse('"{:');
//            return badParse;
//        }

			try {
				return JSONNative.parse(text, reviver);
			}catch (err:Error) {
				// Log.log("Unable to do native parse.", Log.DEBUG);
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