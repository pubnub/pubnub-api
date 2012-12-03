package com.pubnub.operation {
	import com.pubnub.Pn;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class InitOperation extends Operation {
		
		override public function createURL(args:Object = null):void {
			var obj:Object = {	url:origin + "/" + "time" + "/" + 0, 
								channel:"system", 
								uid:Pn.INIT_OPERATION, 
								sessionUUID : sessionUUID };
			//trace('_request : '  + origin + "/" + "time" + "/" + 0);
			super.createURL(obj);
		}
	}
}