using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json.Linq;
using System.Diagnostics;

namespace csharp_webApp
{
    public partial class PubnubTest : System.Web.UI.Page
    {
        //channel name
        string channel = "test-iis";

        //Initialize pubnub state
        pubnub objPubnub = new pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "",      // CIPHER_KEY   (Cipher key is Optional)
            false    // SSL_ON?
        );

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            List<object> info = null;
            Dictionary<string, object> args = new Dictionary<string, object>();
            // Publish string message
            args.Add("channel", channel);
            args.Add("message", "Hello Csharp - IIS");
            info = objPubnub.Publish(args);
            // Print response
            Debug.WriteLine("");
            Debug.WriteLine("Published messages - >");
            if (info != null)
            {
                if (info.Count == 3)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else
            {
                Debug.WriteLine("Error in network connection");
            }

            // Publish message in array format
            JArray jarr = new JArray();
            jarr.Add("Sunday");
            jarr.Add("Monday");
            jarr.Add("Tuesday");
            jarr.Add("Wednesday");
            jarr.Add("Thursday");
            jarr.Add("Friday");
            jarr.Add("Saturday");
            args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("message", jarr);
            info = objPubnub.Publish(args);
            // Print response
            if (info != null)
            {
                if (info.Count == 3)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else
            {
                Debug.WriteLine("Error in network connection");
            }

            // Publish message in object(key - val) format
            JObject jObj = new JObject();
            jObj.Add("Name", "John");
            jObj.Add("age", "25");
            args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("message", jObj);
            info = objPubnub.Publish(args);
            // Print response
            if (info != null)
            {
                if (info.Count == 3)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else
            {
                Debug.WriteLine("Error in network connection");
            }

            Response.Write("See the output at the time of debugging in output window");
        }

        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("");
            pubnub.Procedure Receiver = delegate(object message)
            {
                Debug.WriteLine("[Subscribed data] - " + message);
                return true;
            };
            pubnub.Procedure ConnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure DisconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ReconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ErrorCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", Receiver);                 // callback to get response
            args.Add("connect_cb", ConnectCallback);        // callback to get connect event
            args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
            args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
            args.Add("error_cb", ErrorCallback);            // callback to get error event


            // Subscribe messages
            objPubnub.Subscribe(args);
        }

        protected void btnHistory_Click(object sender, EventArgs e)
        {
            // History
            Dictionary<string, string> args = new Dictionary<string, string>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            List<object> history = objPubnub.History(args);
            Debug.WriteLine("");
            Debug.WriteLine("History messages - > ");
            foreach (object history_message in history)
            {
                Debug.WriteLine(history_message);
            }
        }

        protected void btnTime_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Server Time - > " + objPubnub.Time());
        }

        protected void btnUUID_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Generated UUID - > " + objPubnub.UUID());
        }
    }
}