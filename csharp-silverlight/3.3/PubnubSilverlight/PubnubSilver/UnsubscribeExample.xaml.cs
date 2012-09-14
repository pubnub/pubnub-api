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
using System.Windows.Navigation;
using System.Diagnostics;
using System.Threading;

namespace PubnubSilver
{
    public partial class UnsubscribeExample : Page
    {
        string channel = "hello_world";
        // Initialize Pubnub state
        pubnub objPubnub = new pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "",  // CIPHER_KEY
            false    // SSL_ON?
            );

        public UnsubscribeExample()
        {
            InitializeComponent();
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }
        private void Unsubscribe_Click(object sender, RoutedEventArgs e)
        {
            Dictionary<string, object> arg = new Dictionary<string, object>();
            arg.Add("channel", channel);
            //Unsubscribe messages
            objPubnub.Unsubscribe(arg);
        }

        private void Subscribe_Click(object sender, RoutedEventArgs e)
        {
            lblSubscribe.Text = "Subscribe to the channel " + channel;            
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", new Receiver());            
            objPubnub.Subscribe(args);
        }
        private void Publish_Click(object sender, RoutedEventArgs e)
        {
            lblPublish.Text = "";
            pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        publishedData.Visibility = Visibility.Visible;
                        lblPublish.Text += "\n[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]";
                    }
                });
            };

            Dictionary<string, object> strArgs = new Dictionary<string, object>();
            string message = "Hello Silverlight";
            strArgs.Add("channel", channel);
            strArgs.Add("message", message);
            strArgs.Add("callback", respCallback);
            objPubnub.Publish(strArgs);
        }
    }

}
