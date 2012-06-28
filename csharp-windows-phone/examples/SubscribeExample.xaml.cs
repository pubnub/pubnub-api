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
    public partial class SubscribeExample : PhoneApplicationPage
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

        public SubscribeExample()
        {
            InitializeComponent();
        }

        private void btnSubscribe_Click(object sender, RoutedEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Subscribed to channel " + channel);
            Pubnub.ResponseCallback respCallback = delegate(object message)
            {
                object[] messages = (object[])message;

                if (messages != null && messages.Count() > 0)
                {
                    for (int i = 0; i < messages.Count(); i++)
                    {
                        System.Diagnostics.Debug.WriteLine(messages[i]);
                    }
                }

            };
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", respCallback);
            pubnub.Subscribe(args);
        }
    }
}