using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using Newtonsoft.Json.Linq;
using System.Web.Script.Serialization;
using Pubnub;

namespace pubnub_pub
{
    class PublishExample
    {
        static public void Main()
        {
            // -----------------
            // Init Pubnub Class
            // -----------------
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",  //CIPHER_KEY   
                false    // SSL_ON?
            );

            string channel = "test_channel";

            //// ---------------
            //// Publish String  Message
            //// ---------------
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("message", "Hello Csharp - mono");

            List<object> info = objPubnub.Publish(args);

            Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " +info[2] + "]");
           


            // ---------------
            // Publish   Message in array format
            // ---------------
            args = new Dictionary<string, object>();

            string[] objArr = new string[7];

            objArr[0] = "Sunday";
            objArr[1] = "Monday";
            objArr[2] = "Tuesday";
            objArr[3] = "Wednesday";
            objArr[4] = "Thrusday";
            objArr[5] = "Friday";
            objArr[6] = "Saterday";

            args.Add("channel", channel);
            args.Add("message", objArr);
            info = objPubnub.Publish(args);

            // ----------------
            // Publish Response
            // ----------------
            Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
			
			//Publish Message In Object Format
            args = new Dictionary<string, object>();
            Dictionary<string, object> objDict = new Dictionary<string, object>();

            objDict.Add("Name", "Jhon");            
            objDict.Add("Age", "25");

            args.Add("channel", channel);
            args.Add("message", objDict);
            info = objPubnub.Publish(args);
            Console.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            Console.ReadKey();
           

        }

    }
}
