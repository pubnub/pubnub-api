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
using Newtonsoft.Json.Linq;
using System.Diagnostics;

namespace PubnubSilver
{
    public partial class PubnubTest : Page
    {
        string channel = "hello_world";
        // Initialize Pubnub state
        pubnub objPubnub = new pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "",      // CIPHER_KEY (Cipher key is Optional)
            false    // SSL_ON?
            );
        
        public PubnubTest()
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
            Receiver recv = new Receiver();
            recv.subscribeBlock = lblSubscribe;
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);            
            args.Add("callback", recv);
            
            objPubnub.Subscribe(args);
        }
        private void Publish_Click(object sender, RoutedEventArgs e)
        {
            lblPublish.Text = "";
            pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        publishedData.Visibility = Visibility.Visible;
                        lblPublish.Text += "\n[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]";
                    }
                });
            };

            Dictionary<string, object> strArgs = new Dictionary<string, object>();
            string message = "Hello Silverlight";
            strArgs.Add("channel", channel);
            strArgs.Add("message", message);
            strArgs.Add("callback", respCallback);
            objPubnub.Publish(strArgs);

            Dictionary<string, object> arrArgs = new Dictionary<string, object>();
            JArray jarr = new JArray();
            jarr.Add("Sunday");
            jarr.Add("Monday");
            jarr.Add("Tuesday");
            jarr.Add("Wednesday");
            jarr.Add("Thursday");
            jarr.Add("Friday");
            jarr.Add("Saturday");

            arrArgs.Add("channel", channel);
            arrArgs.Add("message", jarr);
            arrArgs.Add("callback", respCallback);
            objPubnub.Publish(arrArgs);

            Dictionary<string, object> objArgs = new Dictionary<string, object>();

            JObject objDict = new JObject();
            JObject obj = new JObject();
            objDict.Add("Student", "Male");
            obj.Add("Name", "John");
            obj.Add("age", "25");
            objDict.Add("Info", obj);

            objArgs.Add("channel", channel);
            objArgs.Add("message", objDict);
            objArgs.Add("callback", respCallback);
            objPubnub.Publish(objArgs);
        }
        private void History_Click(object sender, RoutedEventArgs e)
        {
            pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;
                UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        histMessage.Visibility = Visibility.Visible;
                        for (int i = 0; i < result.Count(); i++)
                        {

                            if (!(lHistory.Items.Contains(result[i].ToString())))
                            {
                                lHistory.Items.Add(result[i].ToString());
                            }
                        }
                    }
                });
            };
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            args.Add("callback", respCallback);
            objPubnub.History(args); 
        }

        private void HereNow_Click(object sender, RoutedEventArgs e)
        {
            pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        hereNowData.Visibility = Visibility.Visible;
                        lblHereNow.Text += "\n" + result[0].ToString();
                    }
                });
            };

            objPubnub.Here_Now(channel, respCallback);
        }

        public void timedelegate(object response)
        {
            List<object> result = (List<object>)response;
            UIThread.Invoke(() => lblTime.Text = " Time is : " + result[0].ToString());
        }
        private void Time_Click(object sender, RoutedEventArgs e)
        {
            objPubnub.Time(timedelegate);
        }

        private void btnUUID_Click(object sender, RoutedEventArgs e)
        {
            lblUUID.Text = "Generated UUID - > " + objPubnub.UUID(); 
        }

        private void DetailedHistory_Click(object sender, RoutedEventArgs e)
        {
            pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        detailedHistoryData.Visibility = Visibility.Visible;
                        lblDetailedHistory.Text += "\n" + result[0].ToString();
                    }
                });
            };
            objPubnub.DetailedHistory(channel, respCallback, 10);
        }

        private void Presence_Click(object sender, RoutedEventArgs e)
        {
            lblPresence.Text = "Presence to the channel " + channel;
            Receiver recv = new Receiver();
            recv.subscribeBlock = lblPresence;
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", recv);

            objPubnub.Presence(args);
        }
    }
}
