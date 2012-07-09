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
using Newtonsoft.Json.Linq;

namespace CSharp_WP7
{
    public partial class PubnubTest : PhoneApplicationPage
    {
        //Channel name
        string channel = "hello_world";

        // Initialize pubnub state
        Pubnub pubnub = new Pubnub(
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

        private void btnPublish_Click(object sender, RoutedEventArgs e)
        {
            Pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;

                if (result != null && result.Count() > 0)
                {  
                    System.Diagnostics.Debug.WriteLine("[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]");
                }
            };

            // Publish string  message            
            Dictionary<string, object> strArgs = new Dictionary<string, object>();
            string message = "Hello Windows Phone 7";
            strArgs.Add("channel", channel);
            strArgs.Add("message", message);
            strArgs.Add("callback", respCallback);
            pubnub.Publish(strArgs);

            // Publish message in array format
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
            pubnub.Publish(arrArgs);

            // Publish message in Dictionary format
            Dictionary<string, object> objArgs = new Dictionary<string, object>();
            JObject obj = new JObject();
            obj.Add("Name", "Jhon");
            obj.Add("age", "25");
            
            objArgs.Add("channel", channel);
            objArgs.Add("message", obj);
            objArgs.Add("callback", respCallback);
            pubnub.Publish(objArgs);
        }

        private void btnSubscribe_Click(object sender, RoutedEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Subscribed to channel " + channel);
            
            //Subscribe messages
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", new Receiver());
            pubnub.Subscribe(args);
        }

        private void btnHistory_Click(object sender, RoutedEventArgs e)
        {
            Pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;
                
                if (result != null && result.Count() > 0)
                {
                    for (int i = 0; i < result.Count(); i++)
                    {
                        System.Diagnostics.Debug.WriteLine(result[i]);
                    }
                }
            };
            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            args.Add("callback", respCallback);
            pubnub.History(args); 
        }

        private void btnTime_Click(object sender, RoutedEventArgs e)
        {
            Pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;
                System.Diagnostics.Debug.WriteLine("Server Time : " + result[0]);
            };
            pubnub.Time(respCallback);
        }

        private void btnUUID_Click(object sender, RoutedEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("UUID - > " + pubnub.UUID()); 
        }
    }
}