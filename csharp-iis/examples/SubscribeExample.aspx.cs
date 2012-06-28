using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace csharp_webApp
{
    public partial class SubscribeExample : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // channel name
            string channel = "test-iis";

            pubnub objPubnub = new pubnub(
               "demo",  // PUBLISH_KEY
               "demo",  // SUBSCRIBE_KEY
               "demo",  // SECRET_KEY
               "",      // CIPHER_KEY   (Cipher key is Optional)
               false    // SSL_ON?
           );

            System.Diagnostics.Debug.WriteLine("Subscribe to channel " + channel);
            pubnub.Procedure callback = delegate(object message)
            {
                System.Diagnostics.Debug.WriteLine(message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", callback);

            // Subscribe to channel
            objPubnub.Subscribe(args);
        }
    }
}