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
using System.Windows.Threading;
using Newtonsoft.Json.Linq;
using System.Threading;

namespace silverlight_demo_new
{
    public partial class PublishExample : Page
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
        public PublishExample()
        {
            InitializeComponent();
            
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }

        private void Publish_Click(object sender, RoutedEventArgs e)
        {
            Dictionary<string, object> strArgs = new Dictionary<string, object>();
            string message = "Hello Silverlight";
            strArgs.Add("channel", channel);
            strArgs.Add("message", message);
            objPubnub.Publish(strArgs, delegate(object response)
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
            });

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
            objPubnub.Publish(arrArgs, delegate(object response)
            {
                List<object> result = (List<object>)response;

                UIThread.Invoke(() =>
                {
                    if (result != null && result.Count() > 0)
                    {
                        lblPublish.Text += "\n[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]";
                    }
                });
            });

            Dictionary<string, object> objArgs = new Dictionary<string, object>();
            
            JObject obj = new JObject();
            obj.Add("Name", "Jhon");
            obj.Add("age", "25");

            objArgs.Add("channel", channel);
            objArgs.Add("message", obj);
            objPubnub.Publish(objArgs, delegate(object response)
            {
                List<object> result = (List<object>)response;

                UIThread.Invoke(() => 
                    {
                    if (result != null && result.Count() > 0)
                    {
                        lblPublish.Text += "\n[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]";
                    }
                    });
            });
            
        }
    }
}
