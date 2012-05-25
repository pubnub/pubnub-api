using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace pubnub_pub
{
    class HistoryExample
    {
        static public void Main()
        {
            // Init Pubnub Class
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "demo",  //CIPHER_KEY   
                false    // SSL_ON?
            );
            string channel = "test_channel";

            // History
            Dictionary<string, string> args = new Dictionary<string, string>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            List<object> history = objPubnub.History(args);
            foreach (object history_message in history)
            {
                Console.Write("History Message: ");
                Console.WriteLine(history_message);
            }

            // Get PubNub Server Time
            object timestamp = objPubnub.Time();
            Console.WriteLine("Server Time: " + timestamp.ToString());
            Console.ReadKey();
        }
    }
}
