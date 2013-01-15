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

namespace PubnubWindowsPhone
{
    public partial class DemoStart : PhoneApplicationPage
    {
        public DemoStart()
        {
            InitializeComponent();
        }

        private void btnContinue_Click(object sender, RoutedEventArgs e)
        {
            string channel = txtChannel.Text.Trim();
            bool ssl = chkSSL.IsChecked.Value;
            string secretKey = txtSecret.Text;
            string cipherKey = txtCipher.Text;
            string sessionUUID = txtUUID.Text;


            Uri nextPage = new Uri(string.Format("/PubnubOperation.xaml?channel={0}&ssl={1}&cipherkey={2}&secretkey={3}&uuid={4}", channel, ssl, cipherKey, secretKey,sessionUUID), UriKind.Relative);
            NavigationService.Navigate(nextPage);
        }
    }
}