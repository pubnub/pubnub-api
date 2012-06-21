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
    public partial class UUIDExample : PhoneApplicationPage
    {
        public UUIDExample()
        {
            InitializeComponent();
        }

        private void btnUUID_Click(object sender, RoutedEventArgs e)
        {
            // Initialize pubnub state
            Pubnub pubnub = new Pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY (Cipher key is Optional)
                false    // SSL_ON?
                );
            System.Diagnostics.Debug.WriteLine("UUID - > " + pubnub.UUID()); 

        }
    }
}