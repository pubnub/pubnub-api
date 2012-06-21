using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace csharp
{
    class HistoryExample
    {
        static public void Main()
        {
            //Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );
            //channel name
            string channel = "hello-world";

            // History
            Dictionary<string, string> args = new Dictionary<string, string>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            List<object> history = objPubnub.History(args);
            Console.Write("History Message: ");
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
