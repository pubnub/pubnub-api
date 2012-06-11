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

namespace silverlight_demo_new
{
    public partial class SubscribeExample : Page
    {
        string channel = "test_channel1";
        // Initialize Pubnub State
        pubnub objPubnub = new pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "demo",  //CIPHER_KEY
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
            objPubnub.Subscribe(
                channel,
                delegate(object message)
                {
                    object[] messages = (object[])message;
                    UIThread.Invoke(() =>
                    {
                        if (messages != null && messages.Count() > 0)
                        {
                            for (int i = 0; i < messages.Count(); i++)
                            {
                                if (!(lSubscribe.Items.Contains(messages[i].ToString())))
                                {
                                    lSubscribe.Items.Add(messages[i].ToString());
                                }
                            }
                        }
                    });
                }
            );
        }

    }
}
