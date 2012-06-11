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
    public partial class UUIDExample : Page
    {
        string channel = "test_channel1";
        // Initialize the Pubnub class -- 1
        pubnub objPubnub = new pubnub(
                                                "demo",  // PUBLISH_KEY
                                                "demo",  // SUBSCRIBE_KEY
                                                "demo",  // SECRET_KEY
                                                "demo",    //CIPHER_KEY
                                                false    // SSL_ON?
                                                );
        public UUIDExample()
        {
            InitializeComponent();
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }

        private void btnUUID_Click(object sender, RoutedEventArgs e)
        {
            lblUUID.Text = "Generated UUID - > " + objPubnub.UUID(); 
        }
    }
}
