/**
 * Author: WikiFlashed
 * Released under: MIT or whatever license allowed by PubNub.
 * Use of this file at your own risk. WikiFlashed holds no responsibility or liability to what you do with this.
 */
package com.fantom.net.pubnub 
{
    import com.adobe.serialization.json.JSON;
    import com.adobe.crypto.MD5;
    import com.adobe.webapis.URLLoaderBase;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.SetIntervalTimer;
    import flash.utils.Timer;
 
    /**
     * PubNub Static Class
     * 
     * This should allow creating threads of listeners to each individual channel
     * 
     * @author Fan
     */
    public class PubNub extends EventDispatcher
    {
        public static var LIMIT:int = 1700;             
        private static var INSTANCE:PubNub;     
        private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
 
        public var initialized:Boolean = false;         
        public var origin:String = "http://pubsub.pubnub.com";          
        public var ssl:Boolean = false;
        public var interval:Number = 10;
 
        private var publish_key:String = "demo";
        private var sub_key:String = "demo";
        private var secret_key:String = null;
        private var subscriptions:Array;
 
        private var start_time_token:Number = 0;
        private var queue:Array;
 
        public function PubNub(enforcer:SingletonEnforcer) 
        {
 
        }
 
        public static function getInstance():PubNub
        {
            if (!INSTANCE) {
                INSTANCE = new PubNub(new SingletonEnforcer());
            }
            return INSTANCE;
        }
 
        /**
         * 启动
         * Hash Array
         * origin = https:// or http://
         * @param       config
         */
        public function init(config:Object):void
        {
            if(config.ssl && config.origin) {
                origin = "https://" + config.origin;
            } else if (config.origin) {
                origin = "http://" + config.origin;
            }
 
            if(config.publish_key) {
                publish_key = config.publish_key;
            }
 
            if(config.sub_key) {
                sub_key = config.sub_key;
            }
 
            if(config.secret_key) {
                secret_key = config.secret_key;
            }
 
            if (config.push_interval) {
                interval = config.push_interval;
            }
 
            queue = [];
            subscriptions = [];
 
            function timeHandler( evt:Event ):void {
                //trace("[PubNub] Subscription Handler Returned");
                //var myUID:String = uid;
                var node:Object = queue["init"];
                var loader:URLLoader = node.loader;
                if ( evt.type == Event.COMPLETE ) {
                    try {
                        var result:Object = JSON.decode(loader.data);
                        start_time_token = result[0];
                        trace("[PubNub] init complete: " + start_time_token);
                    } catch (e:*) {
                        trace("[PubNub] Bad JSON Content");
                    }
                    initialized = true; 
                    dispatchEvent(new PubNubEvent(PubNubEvent.INIT));
                }
            }
            var url:String = origin + "/" + "time" + "/" + 0;
            // Loads Time Token
            _request( { url:url, channel:"system", handler:timeHandler, uid:"init" } );
        }               
 
        /**
         * Wrapper for function below
         * @param       args
         */
        public static function publish(args:Object):void
        {
            if (!INSTANCE.initialized) {
                throw("[PUBNUB] Not initialized yet");
            }                   
            INSTANCE._publish(args);
        }
 
        /**
         * Broadcasts a message
         * args: { callback:Function, channel:"String", message:"String", }
         * 传递性息
         * @param       args
         */
        public function _publish(args:Object):void
        {
            var onResult:Function       = args.callback || dispatchEvent;
 
            if (!args.channel || !args.message) {
                onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Channel Not Given and/or Message"], timeout:1000 } ));
                return;
            }
 
            var channel:String          = args.channel;
            var message:String          = JSON.encode(args.message);
            var signature:String        = "0";
 
            if (secret_key) {
                // Create the signature for this message
                // Using Crypto digest, md5
                var concat:String = publish_key + "/" + sub_key + "/" + secret_key + "/" + channel + "/" + message;
                signature = MD5.hash(concat);
            }
 
            if (message.length > LIMIT) {
                onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Message Too Long (" + LIMIT + ")"], timeout:1000 } ));
                return;
            }
 
            var uid:String = _uid();
 
            function publishHandler( evt:Event ):void {
                var node:Object = queue[uid];
                var loader:URLLoader = node.loader;
                if ( evt.type == Event.COMPLETE ) {
                    try {
                        var result:Object = JSON.decode(loader.data);                           
                        onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:result, timeout:1 } ));
                    } catch (e:*) {
                        trace("[PubNub] Bad Data Content Ignored");
                    }
                } else {
                    onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Connection Issue"], timeout:1000 } ));
                }
                node.loader.close();
                node.loader = null;
                node.handler = null;
            }
 
            var url:String = origin + "/" + "publish" + "/" + publish_key + "/" + sub_key + "/" + signature + "/" + _encode(channel) + "/" + 0 + "/" +_encode(message);
            //trace("[PubNub] publish "+uid+": "+url);
            _request( { url:url, channel:channel, handler:publishHandler, uid:uid } );
        }
 
        /**
         * Subscription Wrapper
         * @param       args
         */
        public static function subscribe(args:Object):void
        {
            if (!INSTANCE.initialized) {
                throw("[PUBNUB] Not initialized yet");
            }                   
            INSTANCE._subscribe(args);
        }
 
        /**
         * Subscribes to a channel
         * args: { callback:Function, channel:"String" }
         * @param       args
         */
        public function _subscribe(args:Object):void
        {
            var onResult:Function       = args.callback || dispatchEvent;
 
            if (!args.callback) {
                throw("[PubNub] Missing Callback Function");
                return;
            }
 
            if (!args.channel) {
                onResult(new PubNubEvent(PubNubEvent.PUBLISH, { channel:channel, result:[-1,"Channel Not Given"], timeout:1000 } ));
                return;
            }
 
            var channel:String          = args.channel;
 
            var time:Number = start_time_token;
            if (!subscriptions[channel])
            {
                subscriptions[channel] = {}
            }
 
            if (subscriptions[channel].connected)
            {
                onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, { channel:channel, result:[-1, "Already Connected"], timeout:1000 } ));
                return;
            }
 
            subscriptions[channel].connected = true;
            var url:String = origin + "/" + "subscribe" + "/" + sub_key + "/" + _encode(channel) + "/" + 0;
            var uid:String = _uid();
 
            function subHandler( evt:Event ):void {
                //trace("[PubNub] Subscription Handler Returned");
                //var myUID:String = uid;
                var node:Object = queue[uid];
                var loader:URLLoader = node.loader;
 
                if (!subscriptions[channel].connected) {
                    // Stops the connection or any further listening loops
                    loader.close();
                    delete node.loader;
                    delete node.channel;
                    delete node.uid;
                    delete node.timetoken;
                    delete node.request;
                    delete queue[uid];
                    return;
                }
                var timer:Timer;
 
                if ( evt.type == Event.COMPLETE ) {
                    try {
                        var result:Object = JSON.decode(loader.data);
                        var updatedTime:Number = 0;
                        if(result is Array) {
                            var messages:Array = result[0];
                            if(messages) {
                                for (var i:int = 0; i < messages.length; i++) {
                                    onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, { channel:channel, result:[i+1,messages[i]], timeout:1 } ));        
                                }
                            }
                            updatedTime = result[1];
                            //trace(updatedTime)
                        }
                    } catch (e:Error) {
                        trace("[PubNub] Bad Data Content Ignored");
                    }
 
                    node.tries = 0;
 
                    timer = new Timer(interval, 1);
                    timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
                        _request({ url:url, channel:channel, handler:subHandler, uid:uid, timetoken:updatedTime });
                    });
                    timer.start();
                } else {
                    // Possibly Network Issue, then try again after 1 second.
                    onResult(new PubNubEvent(PubNubEvent.SUBSCRIBE, { channel:channel, result:[ -1, "Connection Issue"], timeout:1000 } ));                                     
                    //if (loader.data == null || loader.data == "") {
                    // Problems with the load or empty data
                    node.tries++;
                    //}
                    if (node.tries == 30) {
                        // After 30 tries, seeming the network is now dead after 30 seconds.
                        // Dispatches error event
                        _unsubscribe({ channel:channel, uid:uid });
                        dispatchEvent(new PubNubEvent(PubNubEvent.ERROR, { channel:channel, message:"Channel Dropped" } ));
                    } else {
                        timer = new Timer(1000, 1);
                        timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
                            _request({ url:url, channel:channel, handler:subHandler, uid:uid, timetoken:time });
                        });
                        timer.start();
                    }
                }
            }
 
            _request( { url:url, channel:channel, handler:subHandler, uid:uid, timetoken:time } );
        }
 
        /**
         * UnSubscription Wrapper
         * @param       args
         */
        public static function unsubscribe(args:Object):void
        {
            if (!INSTANCE.initialized) {
                throw("[PUBNUB] Not initialized yet");
            }                   
            INSTANCE._unsubscribe(args);
        }
 
        /**
         * UnSubscribes to a channel
         * args: { callback:Function, channel:"String" }
         * @param       args
         */
        public function _unsubscribe(args:Object):void
        {
            var onResult:Function       = args.callback || dispatchEvent;                       
 
            if (!args.channel) {
                onResult(new PubNubEvent(PubNubEvent.UNSUBSCRIBE, { channel:channel, result:[-1,"Channel Not Given"], timeout:1000 } ));
                return;
            }
            var channel:String          = args.channel;
 
            if (subscriptions[channel] && subscriptions[channel].connected)
            {
                subscriptions[channel].connected =  false;
            }
 
            var event:PubNubEvent = new PubNubEvent(PubNubEvent.UNSUBSCRIBE, { channel:channel, result:[1, "Channel '" + channel + "' Unsubscribed"], timeout:1000 } );
            onResult(event);
        }
 
        /**
         * Helper Functions 
         * ==============================================
         */
 
        /**
         * Makes a pub nub request
         * @param       args
         */
        public function _request(args:Object):void
        {
            var node:Object = queue[args.uid] || { tries:0 };
            var loader:URLLoader = node.loader;
            var url:String = args.url;
            if (args.timetoken != null) {                               
                url += "/" + args.timetoken;
            }
            trace("[PubNub] request: "+url);
            if (!loader) {
                node.loader = loader = new URLLoader();                 
                loader.addEventListener( Event.COMPLETE, args.handler );
                loader.addEventListener( IOErrorEvent.IO_ERROR, args.handler );
                loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, args.handler );                             
                node.request = new URLRequest(url);
            }
            var r:URLRequest = node.request;
            r.url = url;
            loader.load(node.request);
            node.uid = args.uid;
            node.channel = args.channel;
            queue[args.uid] = node;
        }
 
        /**
         * Encodes a string into some format
         * Should be the escape function
         * @param       args
         * @return
         */
        public function _encode(args:String):String
        {
 
            return escape(args);
        }
 
        /**
         * Apply function to all elements in a table
         * @param       f
         * @param       array
         * @return
         */
        public function _map(f:Function, array:Array):Array
        {
            return [];
        }
 
        public function _uid():String
        {
            var uid:Array = new Array(36);
            var index:int = 0;
 
            var i:int;
            var j:int;
 
            for (i = 0; i < 8; i++)
            {
                uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
            }
 
            for (i = 0; i < 3; i++)
            {
                uid[index++] = 45; // charCode for "-"
 
                for (j = 0; j < 4; j++)
                {
                    uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
                }
            }
 
            uid[index++] = 45; // charCode for "-"
 
            var time:Number = new Date().getTime();
            // Note: time is the number of milliseconds since 1970,
            // which is currently more than one trillion.
            // We use the low 8 hex digits of this number in the UID.
            // Just in case the system clock has been reset to
            // Jan 1-4, 1970 (in which case this number could have only
            // 1-7 hex digits), we pad on the left with 7 zeros
            // before taking the low digits.
            var timeString:String = ("0000000" + time.toString(16).toUpperCase()).subst    return String.fromCharCode.apply(null, uid);
        }               
 
    }   
}
 
internal class SingletonEnforcer{}
