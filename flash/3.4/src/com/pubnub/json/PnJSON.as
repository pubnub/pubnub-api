package com.pubnub.json {

public class PnJSON {

    static public var switchTry:Boolean = true;			//check which lib is the right way on parse

    static public function parse(text:String, reviver:Function = null):Object {

        var parsedJSON:Object;

        try {
            parsedJSON = selectJSONParse(parsedJSON, text, reviver);
        } catch (err:Error) {
            PnJSON.switchTry = !PnJSON.switchTry;

            parsedJSON = selectJSONParse(parsedJSON, text, reviver);
        }
        return parsedJSON;
    }

    private static function selectJSONParse(parsedJSON:Object, text:String, reviver:Function):Object {
        if (PnJSON.switchTry) {
            parsedJSON = JSONNative.parse(text, reviver);
        } else {
            parsedJSON = JSON3dParty.parse(text);
        }
        return parsedJSON;
    }

    static public function stringify(value:Object, replacer:* = null, space:* = null):String {
        try {
            if (PnJSON.switchTry) {
                return JSONNative.stringify(value, replacer, space);
            } else {
                return JSON3dParty.stringify(value);
            }
        } catch (err:Error) {
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
