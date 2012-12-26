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
    public partial class MainPage : PhoneApplicationPage
    {
        // Constructor
        public MainPage()
        {
            InitializeComponent();
        }

        private void btnContinue_Click(object sender, RoutedEventArgs e)
        {
            string channel = txtChannel.Text.Trim();
            bool ssl = chkSSL.IsChecked.Value;
            string secretKey = txtSecret.Text;
            string cipherKey = txtCipher.Text;


            Uri nextPage = new Uri(string.Format("/PubnubOperation.xaml?channel={0}&ssl={1}&cipherkey={2}&secretkey={3}",channel,ssl,cipherKey,secretKey), UriKind.Relative);
            NavigationService.Navigate(nextPage);
        }
    }


}