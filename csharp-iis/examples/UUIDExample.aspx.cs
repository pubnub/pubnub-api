using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace csharp_webApp
{
    public partial class UUIDExample : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "",      // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );
            Debug.WriteLine("");
            Debug.WriteLine("Generated UUID - > " + objPubnub.UUID());
        }
    }
}