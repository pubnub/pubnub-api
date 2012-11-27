package com.pubnub.operation {
	import com.adobe.net.URI;
	import com.pubnub.loader.ExperimentURLLoader;
	import com.pubnub.loader.PnURLLoaderEvent;
	import com.pubnub.net.URLLoader;
	import org.httpclient.HttpHeader;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class ExperimentOperation extends Operation {
		
		private var expLoader:ExperimentURLLoader;
		
		public function ExperimentOperation() {
			super();
		}
		
		/*override public function send(args:Object):void {
			//super.send(args);
			trace(this, 'send');
			var url:String = args.url;
			uid = args.uid;
			sessionUUID = args.sessionUUID;
			channel = args.channel;
			timetoken = args.timetoken;
			operation = args.operation;
			//trace(operation, timetoken);
            if (timetoken != null ){
                url += "/" + timetoken;
				if (operation == WITH_TIMETOKEN || 
					operation == GET_TIMETOKEN) {
					url += "?uuid=" + sessionUUID;
				}
            }

			if (args.params != null) { 
				if (args.operation != WITH_TIMETOKEN )
					url = args.url + "?" + args.params;
				else
					url = args.url + "&" + args.params;
			}
			this._url = url;
			//trace(operation, url);
			//_loader.load(this._url);
			
			
			var uri:URI = new URI(url);
			var headers:HttpHeader = new HttpHeader();
			expLoader ||= new ExperimentURLLoader();
			//expLoader.load(
		}*/
		
			override protected function init():void {
				trace(this);
				//super.init();
				//_loader = new PnURLLoader(Settings.OPERATION_TIMEOUT);
				_loader = new URLLoader();
				_loader.addEventListener(PnURLLoaderEvent.COMPLETE, onLoaderData);
				_loader.addEventListener(PnURLLoaderEvent.ERROR, onLoaderError);
			}
		
	}

}