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
using System.Text;

namespace silverlight_demo_new
{
    public partial class HistoryExample : Page
    {
        string channel = "test_channel1";
        // Initialize Pubnub state
        pubnub objPubnub = new pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "demo",  //CIPHER_KEY
            false    // SSL_ON?
        );
        public HistoryExample()
        {
            InitializeComponent();
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }

        private void History_Click(object sender, RoutedEventArgs e)
        {
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            objPubnub.History(args, historyDelegate);           
        }
        private void historyDelegate(object response)
        {
            List<object> result = (List<object>)response;
            UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        for (int i = 0; i < result.Count(); i++)
                        {

                            if (!(lHistory.Items.Contains(result[i].ToString())))
                            {
                                lHistory.Items.Add(result[i].ToString());
                            }
                        }
                    }
                });
        }

    }
}
