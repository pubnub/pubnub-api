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
    public partial class PubnubTimeoutSettings : PhoneApplicationPage
    {
        bool ssl = false;
        string secretKey = "";
        string cipherKey = "";
        string sessionUUID = "";
        bool resumeOnReconnect = false;
        
        int subscribeTimeoutInSeconds = 0;
        int operationTimeoutInSeconds = 0;
        int networkMaxRetries = 0;
        int networkRetryIntervalInSeconds = 0;
        int heartbeatIntervalInSeconds = 0;
        
        public PubnubTimeoutSettings()
        {
            InitializeComponent();
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            
            ssl = Boolean.Parse(NavigationContext.QueryString["ssl"].ToString());
            cipherKey = NavigationContext.QueryString["cipherkey"].ToString();
            secretKey = NavigationContext.QueryString["secretkey"].ToString();
            sessionUUID = NavigationContext.QueryString["uuid"].ToString();
            resumeOnReconnect = Boolean.Parse(NavigationContext.QueryString["resumeOnReconnect"].ToString());
        }

        private void btnContinue_Click(object sender, RoutedEventArgs e)
        {
            Int32.TryParse(txtSubscribeTimeout.Text, out subscribeTimeoutInSeconds);
            subscribeTimeoutInSeconds = (subscribeTimeoutInSeconds <= 0) ? 310 : subscribeTimeoutInSeconds;

            Int32.TryParse(txtNonSubscribeTimeout.Text, out operationTimeoutInSeconds);
            operationTimeoutInSeconds = (operationTimeoutInSeconds <= 0) ? 15 : operationTimeoutInSeconds;

            Int32.TryParse(txtNetworkMaxRetries.Text, out networkMaxRetries);
            networkMaxRetries = (networkMaxRetries <= 0) ? 50 : networkMaxRetries;

            Int32.TryParse(txtRetryInterval.Text, out networkRetryIntervalInSeconds);
            networkRetryIntervalInSeconds = (networkRetryIntervalInSeconds <= 0) ? 10 : networkRetryIntervalInSeconds;

            Int32.TryParse(txtHeartbeatInterval.Text, out heartbeatIntervalInSeconds);
            heartbeatIntervalInSeconds = (heartbeatIntervalInSeconds <= 0) ? 10 : heartbeatIntervalInSeconds;

            Uri nextPage = new Uri(string.Format("/PubnubOperation.xaml?ssl={0}&cipherkey={1}&secretkey={2}&uuid={3}&subtimeout={4}&optimeout={5}&retries={6}&retryinterval={7}&beatinterval={8}&resumeOnReconnect={9}", ssl, cipherKey, secretKey, sessionUUID, subscribeTimeoutInSeconds, operationTimeoutInSeconds, networkMaxRetries, networkRetryIntervalInSeconds, heartbeatIntervalInSeconds, resumeOnReconnect), UriKind.Relative);
            NavigationService.Navigate(nextPage);
        }

    }
}