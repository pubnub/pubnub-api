using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace pubnub_pub
{
    class PubnubTest
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

            // define channel
            string channel = "test_channel";

            // Publish String Message            
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("message", "Hello Csharp - mono");
            List<object> info = null;

            info = objPubnub.Publish(args);
            Console.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            // Publish Message in array format            
            args = new Dictionary<string, object>();
            string[] objArr = new string[7];
            objArr[0] = "Sunday";
            objArr[1] = "Monday";
            objArr[2] = "Tuesday";
            objArr[3] = "Wednesday";
            objArr[4] = "Thursday";
            objArr[5] = "Friday";
            objArr[6] = "Saturday";

            args.Add("channel", channel);
            args.Add("message", objArr);

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
            foreach (object history_message in history)
            {
                Console.Write("History Message: ");
                Console.WriteLine(history_message);
            }

            // Get UUID
            string uuid = objPubnub.UUID();
            Console.WriteLine("UUID - " + uuid);

            // Get PubNub Server Time
            object timestamp = objPubnub.Time();
            Console.WriteLine("\nServer Time: " + timestamp.ToString());

            // Subscribe messages
            objPubnub.Subscribe(
                channel,
                delegate(object message)
                {
                    Console.WriteLine("\nMessage - " + message);
                    return true;
                }
            );

            Console.ReadKey();
        }
    }
}
