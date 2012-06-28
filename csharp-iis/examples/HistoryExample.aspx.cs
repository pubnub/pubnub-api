using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace csharp_webApp
{
    public partial class HistoryExample : System.Web.UI.Page
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
                "",      // CIPHER_KEY (Cipher key is Optional)
                false    // SSL_ON?
            );

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
    }
}