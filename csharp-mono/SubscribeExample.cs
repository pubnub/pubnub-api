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

            pubnub.Procedure callback = delegate(object message)
            {
                Console.WriteLine("Message - " + message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", callback);

            //Subscribe messages
            objPubnub.Subscribe(args);
        }
    }
}
