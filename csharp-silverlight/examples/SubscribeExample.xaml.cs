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

namespace silverlight
{
    public partial class SubscribeExample : Page
    {
        string channel = "hello-world";
        // Initialize pubnub state
        pubnub objPubnub = new pubnub(
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

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }

        private void Subscribe_Click(object sender, RoutedEventArgs e)
        {
            lblSubscribe.Text = "Subscribe to the channel " + channel;
            pubnub.ResponseCallback respCallback = delegate(object message)
                {
                    object[] messages = (object[])message;
                    UIThread.Invoke(() =>
                    {
                        if (messages != null && messages.Count() > 0)
                        {
                            subMessage.Visibility = Visibility.Visible;
                            for (int i = 0; i < messages.Count(); i++)
                            {
                                if (!(lSubscribe.Items.Contains(messages[i].ToString())))
                                {
                                    lSubscribe.Items.Add(messages[i].ToString());
                                }
                            }
                        }
                    });
                };
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", respCallback);
            objPubnub.Subscribe(args);
        }
    }
}
