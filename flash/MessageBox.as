 package {

    import flash.display.Sprite;
    import flash.text.TextField;
    import PubNub.*;
    import flash.external.ExternalInterface;



 public class MessageBox extends Sprite {
    
        function MessageBox():void {


//set the channel
var channelName:String = "hello_world_actionscript";
trace("Channel set to " + channelName);

// Initialize pubnub state
var pubnub:PubNub = PubNub.PubNub.getInstance(); 
var config:Object = {    
    push_interval:10,
    publish_key:"demo",
    sub_key:"demo",
    secret_key:"",
    cipher_key:""
}    
pubnub.init(config);

//            pubnub.addEventListener(PubNubEvent.INIT, onPubInit);
//            function onPubInit(event:PubNubEvent):void
//            {
//                var msgArr:Array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
//                var msgObj:Object = {"Name":"Jhon","Age":"25"};
//
//                PubNub.PubNub.publish( { callback:onPublishHandler, channel:channelName, message:"Hello AS3"} ); //string message
//                PubNub.PubNub.publish( { callback:onPublishHandler, channel:channelName, message:msgArr} ); // array
//                PubNub.PubNub.publish( { callback:onPublishHandler, channel:channelName, message:msgObj} ); //object
//            }
//            function onPublishHandler(evt:PubNubEvent):void
//            {
//                trace("[" + evt.data.result[0] + " ," + evt.data.result[1]+ " ," + evt.data.result[2] + "]");
//            }


//Subscribe messages of type string,json array and json object
            pubnub.addEventListener(PubNubEvent.INIT, onSubInit);
            function onSubInit(event:PubNubEvent):void {

                PubNub.PubNub.subscribe({
                    callback:onSubscribeHandler,
                    channel:channelName
                });

                // Presence

                PubNub.PubNub.subscribe({
                    callback:onPresenceHandler,
                    channel:channelName + "-pnpres"
                });
            }

            function onSubscribeHandler(evt:PubNubEvent):void {
                ExternalInterface.call( "console.log", ("Entering onSubscribeHandler()") );
                ExternalInterface.call( "console.log", (this) );
                ExternalInterface.call( "console.log", (evt) );
            }


            function onPresenceHandler(evt:PubNubEvent):void {
                ExternalInterface.call( "console.log", ("Entering onPresenceHandler()") );
                ExternalInterface.call( "console.log", (this) );
                ExternalInterface.call( "console.log", (evt) );
            }

//
//            private function onPresenceHandler(evt:PubNubEvent):void {
//
//                ExternalInterface.call( "console.log", ("Entering onPresenceHandler()") );
//
//                ExternalInterface.call( "console.log", (this) );
//                ExternalInterface.call( "console.log", (INSTANCE) );
//                ExternalInterface.call( "console.log", (evt) );
//
//            }
 
         var msgbox:Sprite = new Sprite();

          // drawing a white rectangle
          msgbox.graphics.beginFill(0xFFFFFF); // white
          msgbox.graphics.drawRect(0,0,300,20); // x, y, width, height
          msgbox.graphics.endFill();
 
          // drawing a black border
          msgbox.graphics.lineStyle(2, 0x000000, 100);  // line thickness, line color (black), line alpha or opacity
          msgbox.graphics.drawRect(0,0,300,20); // x, y, width, height
        
          var textfield:TextField = new TextField()
          textfield.text = "Hi there!"

          addChild(msgbox)   
          addChild(textfield)
        }
     }
  }
