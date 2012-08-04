 package {

    import flash.display.Sprite;
    import flash.text.TextField;
    import PubNub.*;

 
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



//Subscribe messages of type string,json array and json object
pubnub.addEventListener(PubNubEvent.INIT, onSubInit);
function onSubInit(event:PubNubEvent):void
{
    PubNub.PubNub.subscribe( {
        callback:onSubscribeHandler,
        channel:channelName
    } );
}
function onSubscribeHandler(evt:PubNubEvent):void
{  
    trace("[Subscribed data] : " + evt.data.result[1]);
    trace("[Envelop data] : ", evt.data.envelope);
    trace("[Source Channel] : ", evt.data.envelope[2]);
}


 
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
