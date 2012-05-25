using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace pubnub_pub
{
    class SubscribeExample
    {
        static public void Main()
        {
            // Init Pubnub Class
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "demo",  // CIPHER_KEY
                false    // SSL_ON?
            );
            string channel = "test_channel";

            // Subscribe to the channel
            objPubnub.Subscribe(
                channel,
                delegate(object message)
                {
                    Console.WriteLine("Message - " + message);
                    return true;
                }
            );
        }
    }
}
