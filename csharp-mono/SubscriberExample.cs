using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace pubnub_pub
{
    class SubscriberExample
    {
        static public void Main()
        {
            pubnub objPubnub = new pubnub(
                "demo",  	// PUBLISH_KEY
                "demo",  	// SUBSCRIBE_KEY
                "demo",     // SECRET_KEY
                "",     // CIPHER_KEY
                false    	// SSL_ON?
            );
            string channel = "test_channel";

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
