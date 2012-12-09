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
using PubNub_Messaging;
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

        Popup publishPopup = null;

        public PubnubOperation()
        {
            InitializeComponent();
        }

        private void PhoneApplicationPage_Loaded(object sender, RoutedEventArgs e)
        {
            pubnub = new Pubnub("demo", "demo", secretKey, cipherKey, ssl);
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            channel = NavigationContext.QueryString["channel"].ToString();
            ssl = Boolean.Parse(NavigationContext.QueryString["ssl"].ToString());
            cipherKey = NavigationContext.QueryString["cipherkey"].ToString();
            secretKey = NavigationContext.QueryString["secretkey"].ToString();
        }

        protected override void OnBackKeyPress(System.ComponentModel.CancelEventArgs e)
        {
            if (publishPopup != null && publishPopup.IsOpen)
            {
                publishPopup.IsOpen = false;
                this.IsEnabled = true;
                e.Cancel = true;
            }
            base.OnBackKeyPress(e);
        }

        private void btnTime_Click(object sender, RoutedEventArgs e)
        {
            pubnub.time<string>(pubnubCallbackResult);
        }

        private void pubnubCallbackResult(string result)
        {
            Deployment.Current.Dispatcher.BeginInvoke(
                () =>
                    {
                        TextBlock tb = new TextBlock();
                        tb.TextWrapping = TextWrapping.Wrap;
                        tb.Text = result;
                        stackPanel1.Children.Add(tb);
                        svResult.UpdateLayout();
                        svResult.ScrollToVerticalOffset(svResult.ExtentHeight);
                    }
                );
        }

        private void btnPublish_Click(object sender, RoutedEventArgs e)
        {
            this.IsEnabled = false;
            Border border = new Border();
            border.BorderBrush = new SolidColorBrush(Colors.Black);
            border.BorderThickness = new Thickness(5.0);

            StackPanel panel1 = new StackPanel();
            panel1.Background = new SolidColorBrush(Colors.Blue);
            panel1.Width = 300;
            panel1.Height = 300;

            publishPopup = new Popup();
            publishPopup.Height = 300;
            publishPopup.Width = 300;
            publishPopup.VerticalOffset = 100;
            publishPopup.HorizontalOffset = 100;
            PublishMessageUserControl control = new PublishMessageUserControl();
            panel1.Children.Add(control);
            border.Child = panel1;

            publishPopup.Child = border;
            publishPopup.IsOpen = true;
            control.btnOK.Click += (s, args) =>
            {
                publishPopup.IsOpen = false;
                string pubMsg = control.txtPublish.Text;
                pubnub.publish<string>(channel, pubMsg, pubnubCallbackResult);
                TextBlock tb = new TextBlock();
                tb.Text = string.Format("Publishing {0}\n", pubMsg);
                stackPanel1.Children.Add(tb);
                svResult.UpdateLayout();
                svResult.ScrollToVerticalOffset(svResult.ExtentHeight);
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
            pubnub.here_now<string>(channel, pubnubCallbackResult);
        }

        private void btnPresence_Click(object sender, RoutedEventArgs e)
        {
            pubnub.presence<string>(channel, pubnubCallbackResult);
        }

        private void btnSubscribe_Click(object sender, RoutedEventArgs e)
        {
            pubnub.subscribe<string>(channel, pubnubCallbackResult);
        }

        private void btnDetailedHistory_Click(object sender, RoutedEventArgs e)
        {
            pubnub.detailedHistory<string>(channel, 10, pubnubCallbackResult);
        }

        private void svResult_DoubleTap(object sender, GestureEventArgs e)
        {
            MessageBoxResult action = MessageBox.Show("Delete?", "Confirm", MessageBoxButton.OKCancel);
            if (action == MessageBoxResult.OK)
            {
                stackPanel1.Children.Clear();
            }
        }

        private void btnLog_Click(object sender, RoutedEventArgs e)
        {
            string log = Pubnub.AlternateTraceReader();
            TextBlock tb = new TextBlock();
            tb.Text = log;
            tb.TextWrapping = TextWrapping.Wrap;
            stackPanel1.Children.Add(tb);
            svResult.UpdateLayout();
            svResult.ScrollToVerticalOffset(svResult.ExtentHeight);
            
        }

        private void btnUnsubscribe_Click(object sender, RoutedEventArgs e)
        {
            pubnub.unsubscribe<string>(channel, pubnubCallbackResult);
        }

        private void btnPresenceUnsub_Click(object sender, RoutedEventArgs e)
        {
            pubnub.presence_unsubscribe<string>(channel, pubnubCallbackResult);
        }


    }
}