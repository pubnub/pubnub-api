package {

import flash.external.ExternalInterface;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.system.Security;
import flash.utils.setTimeout;


import flash.display.Sprite;
import flash.system.Security;
import flash.system.System;
import flash.text.TextField;

import PubNub.*;

import flash.external.ExternalInterface;
import flash.utils.setTimeout;

public class MessageBox extends Sprite {

    function MessageBox():void {


		//set the channel

//        Security.allowDomain("*");
//        Security.allowInsecureDomain("*");

        var channelName:String = "hello_world_flash";
        trace("Channel set to " + channelName);

		// Initialize pubnub state
        var pubnub:PubNub = PubNub.PubNub.getInstance();
        var config:Object = {
            push_interval:5,
            publish_key:"demo",
            sub_key:"demo",
            secret_key:"",
            cipher_key:null
        }
        pubnub.init(config);

		//            function onPubInit(event:PubNubEvent):void
		//            {
		//                var msgArr:Array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
		//                var msgObj:Object = {"Name":"Jhon","Age":"25"};
		//
		//                PubNub.PubNub.publish( { callback:onPresenceHandler, channel:channelName, message:"Hello AS3"} ); //string message
		//                PubNub.PubNub.publish( { callback:onPublishHandler, channel:channelName, message:msgArr} ); // array
		//                PubNub.PubNub.publish( { callback:onPublishHandler, channel:channelName, message:msgObj} ); //object
		//            }
		//            function onPublishHandler(evt:PubNubEvent):void
		//            {
		//                trace("[" + evt.data.result[0] + " ," + evt.data.result[1]+ " ," + evt.data.result[2] + "]");
		//            }


        pubnub.addEventListener(PubNubEvent.INIT, onSubInit);

        function onSubInit(event:PubNubEvent):void {
			trace('onSubInit');
            callExternalInterface("console.log", ("init()"));
            callExternalInterface("console.log", ("my uuid is " + pubnub.getSessionUUID()));

//            PubNub.PubNub.publish({
//                        callback:onPresenceHandler,
//                        channel:channelName,
//                        message:"The JSON class lets applications import and export data using JavaScript Object Notation (JSON) format. JSON is an industry-standard data interchange format that is described at http://www.json.org."}
//            );
//
//            PubNub.PubNub.publish({
//                        callback:onPresenceHandler,
//                        channel:channelName,
//                        message:"Pubnub Messaging API 1"}
//            );

            // Subscribe
            PubNub.PubNub.subscribe({
                callback:onSubscribeHandler,
                channel:channelName
            });

            // Presence
//            PubNub.PubNub.subscribe({
//                callback:onPresenceHandler,
//                channel:channelName + "-pnpres"
//            });

            setTimeout(unsub, 5000);

        }

        function unsub():void {
            PubNub.PubNub.unsubscribe({
                callback:onUnSubscribe,
                channel:"hello_world_flash"
            });
        }
		
		function onUnSubscribe(evt:PubNubEvent):void {
			trace('----onUnSubscribe---');
            callExternalInterface("console.log", ("unscribe event received."));
            callExternalInterface("console.log", (evt.data.result));
        }

        function onSubscribeHandler(evt:PubNubEvent):void {
			trace('---onSubscribeHandler---');
            callExternalInterface("console.log", ("subscribe event received."));
            callExternalInterface("console.log", ("Entering onSubscribeHandler()"));
            callExternalInterface("console.log", (evt.data.result));
        }


        function onPresenceHandler(evt:PubNubEvent):void {
            callExternalInterface("console.log", ("presence event received."));
            callExternalInterface("console.log", ("Entering onPresenceHandler()"));
            callExternalInterface("console.log", (this));
            callExternalInterface("console.log", (evt.data.result));
        }

        function onHereNowHandler(evt:PubNubEvent):void {
            callExternalInterface("console.log", ("here_now() event received."));
            callExternalInterface("console.log", ("Entering onHerNowHandler()"));
            callExternalInterface("console.log", (evt.data.result));
        }

        // here_now()
//        pubnub.here_now({
//            callback:onHereNowHandler,
//            channel:channelName
        //});

//
//            private function onPresenceHandler(evt:PubNubEvent):void {
//
//                callExternalInterface( "console.log", ("Entering onPresenceHandler()") );
//
//                callExternalInterface( "console.log", (this) );
//                callExternalInterface( "console.log", (INSTANCE) );
//                callExternalInterface( "console.log", (evt) );
//
//            }

        var msgbox:Sprite = new Sprite();

        // drawing a white rectangle
        msgbox.graphics.beginFill(0xFFFFFF); // white
        msgbox.graphics.drawRect(0, 0, 300, 20); // x, y, width, height
        msgbox.graphics.endFill();

        // drawing a black border
        msgbox.graphics.lineStyle(2, 0x000000, 100);  // line thickness, line color (black), line alpha or opacity
        msgbox.graphics.drawRect(0, 0, 300, 20); // x, y, width, height

        var textfield:TextField = new TextField()
		textfield.embedFonts = false;
        textfield.text = "Hi there!"

        addChild(msgbox)
        addChild(textfield);
		//trace(textfield);
    }
	
	private function callExternalInterface(functionName:String, ...rest):void {
		trace('ExternalInterface.call : ' + functionName, rest);
		if (ExternalInterface.available) {
			ExternalInterface.call(functionName, rest);
		}
	}
}
}
