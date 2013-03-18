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
using PubNubMessaging.Core;
using System.Windows.Controls.Primitives;


namespace PubnubWindowsPhone
{
    public partial class PubnubOperation : PhoneApplicationPage
    {
        Pubnub pubnub;
        string channel = "";
        bool ssl = false;
        string secretKey = "";
        string cipherKey = "";
        string uuid = "";
        bool resumeOnReconnect = false;

        int subscribeTimeoutInSeconds;
        int operationTimeoutInSeconds;
        int networkMaxRetries;
        int networkRetryIntervalInSeconds;
        int heartbeatIntervalInSeconds;

        Popup publishPopup = null;

        public PubnubOperation()
        {
            InitializeComponent();
        }

        private void PhoneApplicationPage_Loaded(object sender, RoutedEventArgs e)
        {
            pubnub = new Pubnub("demo", "demo", secretKey, cipherKey, ssl);
            pubnub.SessionUUID = uuid;
            pubnub.SubscribeTimeout = subscribeTimeoutInSeconds;
            pubnub.NonSubscribeTimeout = operationTimeoutInSeconds;
            pubnub.NetworkCheckMaxRetries = networkMaxRetries;
            pubnub.NetworkCheckRetryInterval = networkRetryIntervalInSeconds;
            pubnub.HeartbeatInterval = heartbeatIntervalInSeconds;
            pubnub.EnableResumeOnReconnect = resumeOnReconnect;
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            ssl = Boolean.Parse(NavigationContext.QueryString["ssl"].ToString());
            cipherKey = NavigationContext.QueryString["cipherkey"].ToString();
            secretKey = NavigationContext.QueryString["secretkey"].ToString();
            uuid = NavigationContext.QueryString["uuid"].ToString();

            subscribeTimeoutInSeconds = Convert.ToInt32(NavigationContext.QueryString["subtimeout"]);
            operationTimeoutInSeconds = Convert.ToInt32(NavigationContext.QueryString["optimeout"]);
            networkMaxRetries = Convert.ToInt32(NavigationContext.QueryString["retries"]);
            networkRetryIntervalInSeconds = Convert.ToInt32(NavigationContext.QueryString["retryinterval"]);
            heartbeatIntervalInSeconds = Convert.ToInt32(NavigationContext.QueryString["beatinterval"]);
            resumeOnReconnect = Boolean.Parse(NavigationContext.QueryString["resumeOnReconnect"].ToString());
        }

        protected override void OnBackKeyPress(System.ComponentModel.CancelEventArgs e)
        {
            if (publishPopup != null && publishPopup.IsOpen)
            {
                publishPopup.IsOpen = false;
                this.IsEnabled = true;
                e.Cancel = true;
            }
            pubnub.EndPendingRequests();
            base.OnBackKeyPress(e);
            
        }

        private void btnTime_Click(object sender, RoutedEventArgs e)
        {
            pubnub.Time<string>(PubnubCallbackResult);
        }

        private void PubnubCallbackResult(string result)
        {
            Deployment.Current.Dispatcher.BeginInvoke(
                () =>
                    {
                        TextBlock textBlock = new TextBlock();
                        textBlock.TextWrapping = TextWrapping.Wrap;
                        textBlock.Text = result;
                        messageStackPanel.Children.Add(textBlock);
                        scrollViewerResult.UpdateLayout();
                        scrollViewerResult.ScrollToVerticalOffset(scrollViewerResult.ExtentHeight);
                    }
                );
        }

        private void PubnubConnectCallbackResult(string result)
        {
            Deployment.Current.Dispatcher.BeginInvoke(
                () =>
                {
                    TextBlock textBlock = new TextBlock();
                    textBlock.TextWrapping = TextWrapping.Wrap;
                    textBlock.Text = result;
                    messageStackPanel.Children.Add(textBlock);
                    scrollViewerResult.UpdateLayout();
                    scrollViewerResult.ScrollToVerticalOffset(scrollViewerResult.ExtentHeight);
                }
                );
        }

        private void PubnubDisconnectCallbackResult(string result)
        {
            Deployment.Current.Dispatcher.BeginInvoke(
                () =>
                {
                    TextBlock textBlock = new TextBlock();
                    textBlock.TextWrapping = TextWrapping.Wrap;
                    textBlock.Text = result;
                    messageStackPanel.Children.Add(textBlock);
                    scrollViewerResult.UpdateLayout();
                    scrollViewerResult.ScrollToVerticalOffset(scrollViewerResult.ExtentHeight);
                }
                );
        }

        private void btnPublish_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            this.IsEnabled = false;
            Border border = new Border();
            border.BorderBrush = new SolidColorBrush(Colors.Black);
            border.BorderThickness = new Thickness(5.0);

            StackPanel publishStackPanel = new StackPanel();
            publishStackPanel.Background = new SolidColorBrush(Colors.Blue);
            publishStackPanel.Width = 300;
            publishStackPanel.Height = 300;

            publishPopup = new Popup();
            publishPopup.Height = 300;
            publishPopup.Width = 300;
            publishPopup.VerticalOffset = 100;
            publishPopup.HorizontalOffset = 100;
            PublishMessageUserControl control = new PublishMessageUserControl();
            publishStackPanel.Children.Add(control);
            border.Child = publishStackPanel;

            publishPopup.Child = border;
            publishPopup.IsOpen = true;
            control.btnOK.Click += (s, args) =>
            {
                publishPopup.IsOpen = false;
                string publishedMessage = control.txtPublish.Text;
                pubnub.Publish<string>(channel, publishedMessage, PubnubCallbackResult);
                TextBlock textBlock = new TextBlock();
                textBlock.Text = string.Format("Publishing {0}\n", publishedMessage);
                messageStackPanel.Children.Add(textBlock);
                scrollViewerResult.UpdateLayout();
                scrollViewerResult.ScrollToVerticalOffset(scrollViewerResult.ExtentHeight);
                publishPopup = null;
                this.IsEnabled = true;
            };
            control.btnCancel.Click += (s, args) =>
            {
                publishPopup.IsOpen = false;
                publishPopup = null;
                this.IsEnabled = true;
            };

        }

        private void btnHereNow_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            pubnub.HereNow<string>(channel, PubnubCallbackResult);
        }

        private void btnPresence_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            pubnub.Presence<string>(channel, PubnubCallbackResult, PubnubConnectCallbackResult);
        }

        private void btnDetailedHistory_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            pubnub.DetailedHistory<string>(channel, 10, PubnubCallbackResult);
        }

        private void scrollViewerResult_DoubleTap(object sender, GestureEventArgs e)
        {
            MessageBoxResult action = MessageBox.Show("Delete?", "Confirm", MessageBoxButton.OKCancel);
            if (action == MessageBoxResult.OK)
            {
                messageStackPanel.Children.Clear();
            }
        }

        private void btnUnsubscribe_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            pubnub.Unsubscribe<string>(channel, PubnubCallbackResult, PubnubConnectCallbackResult, PubnubDisconnectCallbackResult);
        }

        private void btnPresenceUnsub_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            pubnub.PresenceUnsubscribe<string>(channel, PubnubCallbackResult, PubnubConnectCallbackResult, PubnubDisconnectCallbackResult);
        }

        private void btnSubscribe_Click(object sender, RoutedEventArgs e)
        {
            channel = txtChannel.Text;
            pubnub.Subscribe<string>(channel, PubnubCallbackResult, PubnubConnectCallbackResult);
        }

        private void btnDisableNetwork_Click(object sender, RoutedEventArgs e)
        {
            pubnub.EnableSimulateNetworkFailForTestingOnly();
        }

        private void btnEnableNetwork_Click(object sender, RoutedEventArgs e)
        {
            pubnub.DisableSimulateNetworkFailForTestingOnly();
        }

        private void btnDisconnectRetry_Click(object sender, RoutedEventArgs e)
        {
            pubnub.TerminateCurrentSubscriberRequest();
        }

    }
}