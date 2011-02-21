package {
    import flash.external.ExternalInterface;
    import flash.display.Sprite;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.system.Security;
    import flash.utils.setTimeout;

    public class pubnub extends Sprite {

        Security.allowDomain("*");
        Security.allowInsecureDomain("*");

        ExternalInterface.addCallback( "get", function(
            id:Number,
            url:String
        ):void {
            function handler(e:Event):void {
                var loader:URLLoader = URLLoader(e.target)
                ,   data:String      = loader.data
                ,   timeout:int      = 1;

                if (e.type == 'securityError') {
                    data    = '[1,"S"]';
                    timeout = 1000;
                }

                setTimeout( function delayed():void {
                    ExternalInterface.call( "PUBNUB.rdx", id, escape(data) );
                    loader.close();
                }, timeout );
            }

            var loader:URLLoader  = new URLLoader();

            loader.addEventListener( Event.COMPLETE, handler );
            loader.addEventListener( IOErrorEvent.IO_ERROR, handler );
            loader.addEventListener(
                SecurityErrorEvent.SECURITY_ERROR, handler
            );
            loader.load(new URLRequest(url));
        }); 
    }
}
