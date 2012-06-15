using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json.Linq;

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
            "demo",  // CIPHER_KEY   
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
            System.Diagnostics.Debug.WriteLine("");
            System.Diagnostics.Debug.WriteLine("Published messages - >");
            System.Diagnostics.Debug.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

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
            System.Diagnostics.Debug.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            // Publish message in object(key - val) format
            JObject jObj = new JObject();
            jObj.Add("Name", "John");
            jObj.Add("age", "25");
            args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("message", jObj);
            info = objPubnub.Publish(args);
            // Print response
            System.Diagnostics.Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            Response.Write("See the output at the time of debugging in output window");
        }

        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("");
            System.Diagnostics.Debug.WriteLine("Subscribed to channel " + channel);
            pubnub.Procedure callback = delegate(object message)
            {
                System.Diagnostics.Debug.WriteLine("[Subscribed data] - " +message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", callback);

            // Subscribe
            objPubnub.Subscribe(args);
        }

        protected void btnHistory_Click(object sender, EventArgs e)
        {
            // History
            Dictionary<string, string> args = new Dictionary<string, string>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            List<object> history = objPubnub.History(args);
            System.Diagnostics.Debug.WriteLine("");
            System.Diagnostics.Debug.WriteLine("History messages - > ");
            foreach (object history_message in history)
            {
                System.Diagnostics.Debug.WriteLine(history_message);
            }
        }

        protected void btnTime_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("");
            System.Diagnostics.Debug.WriteLine("Server Time - > " + objPubnub.Time());
        }

        protected void btnUUID_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("");
            System.Diagnostics.Debug.WriteLine("Generated UUID - > " + objPubnub.UUID());
        }
    }
}