using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;

namespace CSharp_WP7
{
    public partial class HistoryExample : PhoneApplicationPage
    {
        public HistoryExample()
        {
            InitializeComponent();
        }

        private void btnHistory_Click(object sender, RoutedEventArgs e)
        {
            //Channel name
            string channel = "hello_world";

            // Initialize pubnub state
            Pubnub pubnub = new Pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY (Cipher key is Optional)
                false    // SSL_ON?
                );
            Pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                if (result != null && result.Count() > 0)
                {
                    for (int i = 0; i < result.Count(); i++)
                    {
                        System.Diagnostics.Debug.WriteLine(result[i]);
                    }
                }
            };
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            args.Add("callback", respCallback);
            pubnub.History(args); 
        }
    }
}