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
    public partial class UnsubscribeExample : PhoneApplicationPage
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

        public UnsubscribeExample()
        {
            InitializeComponent();
        }

        private void btnUnsubscribe_Click(object sender, RoutedEventArgs e)
        {
			Dictionary<string, object> arg = new Dictionary<string, object>();
            arg.Add("channel", channel);
            //Unsubscribe messages
            pubnub.Unsubscribe(arg);
        }

        private void btnSubscribe_Click(object sender, RoutedEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Subscribed to channel " + channel);

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", new Receiver());
            pubnub.Subscribe(args);
        }

        private void btnPublish_Click(object sender, RoutedEventArgs e)
        {
            Pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                if (result != null && result.Count() > 0)
                {
                    System.Diagnostics.Debug.WriteLine("[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]");
                }
            };

            // Publish string  message            
            Dictionary<string, object> strArgs = new Dictionary<string, object>();
            string message = "Hello Windows Phone 7";
            strArgs.Add("channel", channel);
            strArgs.Add("message", message);
            strArgs.Add("callback", respCallback);
            pubnub.Publish(strArgs);
        }
    }
}