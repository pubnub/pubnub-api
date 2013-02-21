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
    static public var switchTry:Boolean = true;			//check which lib is the right way on parse

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
				if (PnJSON.switchTry) {
					return JSONNative.parse(text, reviver);
				} else {
					return JSON3dParty.parse(text);
				}
			}catch (err:Error) {
				PnJSON.switchTry = !PnJSON.switchTry;
				// Log.log("Unable to do native parse.", Log.DEBUG);
			}
			if (PnJSON.switchTry) {
				return JSONNative.parse(text, reviver);
			} else {
				return JSON3dParty.parse(text);
			}
		}
		
		static public  function stringify(value:Object, replacer:* = null, space:* = null):String {
			try {
				if (PnJSON.switchTry) {
					return JSONNative.stringify(value, replacer, space);
				} else {
					return JSON3dParty.stringify(value);
				}
			}catch (err:Error) {
				// native JSON works with error here
				PnJSON.switchTry = !PnJSON.switchTry;
			}
			if (PnJSON.switchTry) {
				return JSONNative.stringify(value, replacer, space);
			} else {
				return JSON3dParty.stringify(value);
			}
		}
	}
}
