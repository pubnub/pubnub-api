using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace csharp
{
    class SubscribeExample
    {
        static public void Main()
        {
            //Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY (Cipher key is Optional)
                false    // SSL_ON?
            );
            //channel name
            string channel = "hello-world";

            pubnub.Procedure Receiver = delegate(object message)
            {
                Console.WriteLine("Message - " + message);
                return true;
            };
            pubnub.Procedure ConnectCallback = delegate(object message)
            {
                Console.WriteLine(message);
                return true;
            };
            pubnub.Procedure DisconnectCallback = delegate(object message)
            {
                Console.WriteLine(message);
                return true;
            };
            pubnub.Procedure ReconnectCallback = delegate(object message)
            {
                Console.WriteLine(message);
                return true;
            };
            pubnub.Procedure ErrorCallback = delegate(object message)
            {
                Console.WriteLine(message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", Receiver);                 // callback to get response
            args.Add("connect_cb", ConnectCallback);        // callback to get connect event
            args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
            args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
            args.Add("error_cb", ErrorCallback);            // callback to get error event

            //Subscribe messages
            objPubnub.Subscribe(args);
        }
    }
}
