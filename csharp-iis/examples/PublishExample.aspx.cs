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
    public partial class PublishExample : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // channel name
            string channel = "test-iis";

            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "demo",  // CIPHER_KEY   
                false    // SSL_ON?
            );

            List<object> info = null;
            Dictionary<string, object> args = new Dictionary<string, object>();
            // Publish string  message
            args.Add("channel", channel);
            args.Add("message", "Hello Csharp - IIS");

            info = objPubnub.Publish(args);
            // Print Response
            Debug.WriteLine(" "); ;
            Debug.WriteLine("Published messages - >");
            Debug.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            // Publish message in array format
            args = new Dictionary<string, object>();
            JArray jarr = new JArray();
            jarr.Add("Sunday");
            jarr.Add("Monday");
            jarr.Add("Tuesday");
            jarr.Add("Wednesday");
            jarr.Add("Thursday");
            jarr.Add("Friday");
            jarr.Add("Saturday");

            args.Add("channel", channel);
            args.Add("message", jarr);

            info = objPubnub.Publish(args);
            // Print Response
            Debug.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

            // Publish message in object(key - val) format
            args = new Dictionary<string, object>();
            JObject jObj = new JObject();
            jObj.Add("Name", "John");
            jObj.Add("age", "25");

            args.Add("channel", channel);
            args.Add("message", jObj);

            info = objPubnub.Publish(args);
            // Print Response
            Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
        }
    }
}