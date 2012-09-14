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
using System.Diagnostics;
using System.Threading;

namespace silverlight
{
    public partial class unit_test : Page
    {
        public unit_test()
        {
            InitializeComponent();
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }       

        // -----------------------------------------------------------------------
        // unit-test-all
        // -----------------------------------------------------------------------

        static String publish_key = "demo", subscribe_key = "demo";
        static String secret_key = "demo", cipher_key = "";
        static Boolean ssl_on = false;

        // -----------------------------------------------------------------------
        // Command Line Options Supplied PubNub
        // -----------------------------------------------------------------------

        static pubnub pubnub_user_supplied_options = new pubnub(publish_key, // OPTIONAL (supply None to disable)
                subscribe_key, // REQUIRED
                secret_key, // OPTIONAL (supply None to disable)
                cipher_key, // OPTIONAL (supply None to disable)
                ssl_on // OPTIONAL (supply None to disable)
        );

        // -----------------------------------------------------------------------
        // High Security PubNub
        // -----------------------------------------------------------------------
        static pubnub pubnub_high_security = new pubnub(
            // Publish Key
                "pub-c-a30c030e-9f9c-408d-be89-d70b336ca7a0",

                // Subscribe Key
                "sub-c-387c90f3-c018-11e1-98c9-a5220e0555fd",

                // Secret Key
                "sec-c-MTliNDE0NTAtYjY4Ni00MDRkLTllYTItNDhiZGE0N2JlYzBl",

                // Cipher Key
                "YWxzamRmbVjFaa05HVnGFqZHM3NXRBS73jxmhVMkjiwVVXV1d5UrXR1JLSkZFRr"
                        + "WVd4emFtUm1iR0TFpUZvbiBoYXMgYmVlbxWkhNaF3uUi8kM0YkJTEVlZYVFjBYi"
                        + "jFkWFIxSkxTa1pGUjd874hjklaTFpUwRVuIFNob3VsZCB5UwRkxUR1J6YVhlQWa"
                        + "V1ZkNGVH32mDkdho3pqtRnRVbTFpUjBaeGUgYXNrZWQtZFoKjda40ZWlyYWl1eX"
                        + "U4RkNtdmNub2l1dHE2TTA1jd84jkdJTbFJXYkZwWlZtRnKkWVrSRhhWbFpZVmFz"
                        + "c2RkZmTFpUpGa1dGSXhTa3hUYTFwR1Vpkm9yIGluZm9ybWFNfdsWQdSiiYXNWVX"
                        + "RSblJWYlRGcFVqQmFlRmRyYUU0MFpXbHlZV2wxZVhVNFJrTnR51YjJsMWRIRTJU"
                        + "W91ciBpbmZvcm1hdGliBzdWJtaXR0ZWQb3UZSBhIHJlc3BvbnNlLCB3ZWxsIHJl"
                        + "VEExWdHVybiB0am0aW9uIb24gYXMgd2UgcG9zc2libHkgY2FuLuhcFe24ldWVns"
                        + "dSaTFpU3hVUjFKNllWaFdhRmxZUWpCaQo34gcmVxdWlGFzIHNveqQl83snBfVl3",

                // 2048bit SSL ON - ENABLED TRUE
                false);

        // -----------------------------------------------------------------------
        // Channel | Message Test Data (UTF-8)
        // -----------------------------------------------------------------------
        static string Message = " ~`â¦â§!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
        static pubnub _pubnub;
        static List<String> many_channels = new List<String>(10);
        static Dictionary<string, Int32> status = new Dictionary<string, int>(3);
        static Dictionary<String, Dictionary<string, Int32>> channelStatus = new Dictionary<String, Dictionary<string, Int32>>(many_channels.Capacity);


        static Dictionary<String, Object> threads = new Dictionary<String, Object>(4);

        static Dictionary<string, bool> channelConnected = new Dictionary<string, bool>();

        static int max_retries = 10;
        static int planned_tests = 2;
        static int runthroughs = 0;
        static int delivery_retries = 0;

        // -----------------------------------------------------------------------
        // Unit Test Function
        // -----------------------------------------------------------------------

        static void test(Boolean trial, String name)
        {
            if (trial)
                Debug.WriteLine("PASS " + name);
            else
                Debug.WriteLine("- FAIL - " + name);
        }
        static void UnitTestAll(pubnub pubnub)
        {
            status.Clear();
            threads.Clear();
            many_channels.Clear();
            if (runthroughs >= 2)
            {
                runthroughs = 0;
            }
            _pubnub = pubnub;
            
            if (!status.ContainsKey("sent"))            
                status.Add("sent", 0);
            if (!status.ContainsKey("received"))            
                status.Add("received", 0);
            if (!status.ContainsKey("connections"))           
                status.Add("connections", 0);

            for (int i = 0; i < many_channels.Capacity; i++)
            {
                many_channels.Add("channel_" + i);
                channelConnected[many_channels[i]] = false;
                channelStatus[many_channels[i]] = status;
            }
            subscribeChannels(_pubnub);
        }
        static void subscribeChannels(pubnub pubnub)
        {
            foreach (string _channel in many_channels)
            {
                Thread t = new Thread(delegate()
                {
                Dictionary<String, Object> argsSub = new Dictionary<String, Object>(2);
                argsSub.Add("channel", _channel);
                argsSub.Add("callback", new Receiver());    // callback to get response                    
                // Listen for Messages (Subscribe)
                pubnub.Subscribe(argsSub);
                });
                t.Start();
                if (threads.ContainsKey(_channel))
                    threads[_channel] = t;
                else
                    threads.Add(_channel, t);
                try
                {
                    Thread.Sleep(1000);
                }
                catch (ThreadAbortException e)
                {
                    Debug.WriteLine(e.Message);
                }
            }
        }
        class Receiver : Callback
        {

            public bool responseCallback(string channel, object message)
            {
                object[] results = (object[])message;
                if (results.Length > 0)
                {
                    int sent = Convert.ToInt32((channelStatus[channel])["sent"]);
                    int received = Convert.ToInt32((channelStatus[channel])["received"]);
                    test(received <= sent, "many sends");   
                    received = received + 1;
                    (channelStatus[channel]).Remove("received");
                    (channelStatus[channel]).Add("received", received);
                                     
                    Dictionary<String, Object> args = new Dictionary<String, Object>(1);
                    args.Add("channel", channel);
                    if (channelConnected[channel])
                    {
                        _pubnub.Unsubscribe(args);
                    }
                    //int allReceived = 0;
                    //foreach(var status in channelStatus)
                    //{
                    //    allReceived += Convert.ToInt32(status.Value["received"]);
                    //}
                    //if (allReceived == many_channels.Count)
                    //{
                    //    runthroughs += 1;
                    //    if (runthroughs < planned_tests)
                    //    {
                    //        //UnitTestAll(_pubnub);
                    //    }
                    //}
                    return true;
                }
                else
                    return false;
            }

            public void errorCallback(string channel, object message)
            {
                //Debug.WriteLine("Channel:" + channel + "-" + message.ToString());
            }

            public void connectCallback(string channel)
            {
                if (!channelConnected[channel])
                {
                    pubnub.ResponseCallback histCallback = delegate(object response)
                    {
                        List<object> result = (List<object>)response;
                        test(result != null && result.Count > 0, "history");
                    };
                    Debug.WriteLine("Connected to channel :" + channel);
                    int connections = Convert.ToInt32(status["connections"]);
                    status.Remove("connections");
                    status.Add("connections", connections + 1);
                    publishAndSetStatus(channel, Message);
                   
                    Dictionary<string, object> argshist = new Dictionary<string, object>();
                    argshist.Add("channel", channel);
                    argshist.Add("limit", 1.ToString());
                    argshist.Add("callback", histCallback);
                    _pubnub.History(argshist);
                }
            }
            public void reconnectCallback(string channel)
            {
                Debug.WriteLine("Reconnected to channel :" + channel);
            }
            public void disconnectCallback(string channel)
            {
                Debug.WriteLine("Disconnected to channel :" + channel);
            }
        }
        private void unitTest_Click(object sender, RoutedEventArgs e)
        {
            UnitTestAll(pubnub_high_security);

            //UnitTestAll(pubnub_user_supplied_options);
            //test_subscribe();
            //test_publish();            
            //test_uuid();
            //test_time();
            //test_history();
        }

        static public void test_publish()
        {
            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );

            //define channel
            string channel = "hello-world";
            pubnub.ResponseCallback respCallback = delegate(object response)
            {
                List<object> messages = (List<object>)response;
                if (messages != null && messages.Count > 0)
                {
                    Debug.WriteLine("[" + messages[0] + " , " + messages[1] + "]");
                }
            };
            Dictionary<string, object> strArgs = new Dictionary<string, object>();
            string message = "Hello Silverlight";
            strArgs.Add("channel", channel);
            strArgs.Add("message", message);
            strArgs.Add("callback", respCallback);
            objPubnub.Publish(strArgs);
        }
        static public void test_subscribe()
        {
            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );

            //define channel
            string channel = "hello-world";

            Dictionary<string, object> args = new Dictionary<string, object>();
            args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", new silverlight.Receiver());                // callback to get response
            objPubnub.Subscribe(args);
        }
        static public void test_history()
        {
            pubnub.ResponseCallback histCallback = delegate(object response)
            {
                List<object> result = (List<object>)response;
                Debug.WriteLine("[History data]");
                foreach (object data in result)
                {
                    Debug.WriteLine(data);
                }
            };

            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );

            //define channel
            string channel = "hello-world";

            // History
            Dictionary<string, object> argsHist = new Dictionary<string, object>();
            argsHist.Add("channel", channel);
            argsHist.Add("limit", 3.ToString());
            argsHist.Add("callback", histCallback);
            objPubnub.History(argsHist);            
            
        }
        static public void test_uuid()
        {
            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );

            //Get UUID
            string uuid = objPubnub.UUID();
            Debug.WriteLine("Generated UUID - >  - " + uuid);
        }
        static public void test_time()
        {

            // Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",      // CIPHER_KEY   (Cipher key is Optional)
                false    // SSL_ON?
            );

            // Get PubNub Server Time
            objPubnub.Time(timedelegate);
        }
        public static void timedelegate(object response)
        {
            List<object> result = (List<object>)response;
            Debug.WriteLine(" Time is : " + result[0].ToString());
        }
        public static void publishAndSetStatus(string channel, object message)
        {
            pubnub.ResponseCallback publishCallback = delegate(object response)
            {
                List<object> messages = (List<object>)response;               
                if (messages != null && messages.Count > 2)
                {
                    int sent = Convert.ToInt32((channelStatus[channel])["sent"]);                   
                    (channelStatus[channel]).Remove("sent");                    
                    (channelStatus[channel]).Add("sent", sent + 1);                    
                    test(messages != null, "publish complete");
                    test(messages != null && messages.Count > 2, "publish responce");
                    channelConnected[channel] = true;
                }
                if (messages == null || messages.Count <= 0)
                {
                    delivery_retries += 1;
                    if (max_retries > delivery_retries)
                    {
                        publishAndSetStatus(channel, message);
                    }
                }
            };

            // Publish message      
            Dictionary<string, object> args = new Dictionary<string, object>(2);
            args.Add("channel", channel);
            args.Add("message", message);
            args.Add("callback", publishCallback);
            // publish Response
            _pubnub.Publish(args);
        }

    }
}
