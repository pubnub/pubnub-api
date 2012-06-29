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
           if (info != null)
            {
                if (info.Count == 3) //success
                {
                    Console.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2) //error
                {
                    Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else 
            {
                Console.WriteLine("Error in network connection");
            }

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
			if (info != null)
            {
                if (info.Count == 3)
                {
                    Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2)
                {
                    Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else 
            {
                Console.WriteLine("Error in network connection");
            }

           args = new Dictionary<string, object>();
           Dictionary<string, object> objDict = new Dictionary<string, object>();

            objDict.Add("Name", "John");
            objDict.Add("Age", "25");

            args.Add("channel", channel);
            args.Add("message", objDict);

           info = objPubnub.Publish(args);
           if (info != null)
            {
                if (info.Count == 3)
                {
                    Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2)
                {
                    Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else 
            {
                Console.WriteLine("Error in network connection");
            }

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
			args = new Dictionary<string, object>();
			args.Add("channel", channel);
			args.Add("callback", Receiver);                 // callback to get response
			args.Add("connect_cb", ConnectCallback);        // callback to get connect event
			args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
			args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
			args.Add("error_cb", ErrorCallback);            // callback to get error event

			objPubnub.Subscribe(args);

           Console.ReadKey();
        }

    }
}
