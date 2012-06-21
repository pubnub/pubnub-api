using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace csharp
{
    class PubnubTest
    {
        static public void Main()
        {

            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );

            //define channel
            string channel = "hello-world";

            // Publish string message            
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("message", "Hello Csharp - mono");
            List<object> info = null;

            info = objPubnub.Publish(args);
            Console.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            // Publish message in array format            
            args = new Dictionary<string, object>();
            object[] objArr = new object[7];
            objArr[0] = "Sunday";
            objArr[1] = "Monday";
            objArr[2] = "Tuesday";
            objArr[3] = "Wednesday";
            objArr[4] = "Thursday";
            objArr[5] = "Friday";
            objArr[6] = "Saturday";

            args.Add("channel", channel);
            args.Add("message", objArr);

            // publish Response
            info = objPubnub.Publish(args);
            Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            args = new Dictionary<string, object>();
            Dictionary<string, object> objDict = new Dictionary<string, object>();

            objDict.Add("Name", "Jhon");
            objDict.Add("Age", "25");

            args.Add("channel", channel);
            args.Add("message", objDict);

            info = objPubnub.Publish(args);
            Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            // History
            Dictionary<string, string> argsHist = new Dictionary<string, string>();
            argsHist.Add("channel", channel);
            argsHist.Add("limit", 3.ToString());
            List<object> history = objPubnub.History(argsHist);
            Console.Write("History Messages: ");
            foreach (object history_message in history)
            {
                Console.WriteLine(history_message);
            }

            //Get UUID
            string uuid = objPubnub.UUID();
            Console.WriteLine("UUID - " + uuid);

            // Get PubNub Server Time
            object timestamp = objPubnub.Time();
            Console.WriteLine("\nServer Time: " + timestamp.ToString());

            //Subscribe messages
            pubnub.Procedure callback = delegate(object message)
            {
                Console.WriteLine("Messages - " + message);
                return true;
            };
            args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", callback);

            objPubnub.Subscribe(args);

            Console.ReadKey();
        }

    }
}
