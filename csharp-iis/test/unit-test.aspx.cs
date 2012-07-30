using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;
using System.Diagnostics;

namespace csharp_webApp
{
    public partial class unit_test : System.Web.UI.Page
    {

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

            List<object> info = null;
            Dictionary<string, object> args = new Dictionary<string, object>();
            // Publish string message
            args.Add("channel", channel);
            args.Add("message", "Hello Csharp - IIS");
            info = objPubnub.Publish(args);
            // Print response
            Debug.WriteLine("");
            Debug.WriteLine("Published messages - >");
            if (info != null)
            {
                if (info.Count == 3)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");
                }
                else if (info.Count == 2)
                {
                    Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + "]");
                }
            }
            else
            {
                Debug.WriteLine("Error in network connection");
            }
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

            //Subscribe messages
            pubnub.Procedure Receiver = delegate(object message)
            {
                Debug.WriteLine("Message - " + message);
                return true;
            };
            pubnub.Procedure ConnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure DisconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ReconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ErrorCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", Receiver);                 // callback to get response
            args.Add("connect_cb", ConnectCallback);        // callback to get connect event
            args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
            args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
            args.Add("error_cb", ErrorCallback);            // callback to get error event

            objPubnub.Subscribe(args);
        }
        static public void test_history()
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

            // History
            Dictionary<string, string> args = new Dictionary<string, string>();
            args.Add("channel", channel);
            args.Add("limit", 3.ToString());
            List<object> history = objPubnub.History(args);
            Debug.WriteLine("");
            Debug.WriteLine("History messages - > ");
            foreach (object history_message in history)
            {
                Debug.WriteLine(history_message);
            }
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
            Debug.WriteLine("");
            Debug.WriteLine("Generated UUID - > " + objPubnub.UUID());

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
            Debug.WriteLine("");
            Debug.WriteLine("Server Time - > " + objPubnub.Time());
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            //test_publish();
            //test_subscribe();
            //test_history();
            //test_time();
            //test_uuid();
            UnitTestAll(pubnub_high_security);
            UnitTestAll(pubnub_user_supplied_options);
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

        static Dictionary<String, Object> status = new Dictionary<String, Object>(3);

        static Dictionary<String, Object> threads = new Dictionary<String, Object>(4);

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
            if (runthroughs >= 2)
            {
                runthroughs = 0;
            }

            _pubnub = pubnub;
            if (many_channels.Count <= 0)
            {
                for (int i = 0; i < many_channels.Capacity; i++)
                {
                    many_channels.Add("channel_" + i);
                }
            }
            if (status.ContainsKey("sent"))
                status["sent"] = 0;
            else
                status.Add("sent", 0);
            if (status.ContainsKey("received"))
                status["received"] = 0;
            else
                status.Add("received", 0);
            if (status.ContainsKey("connections"))
                status["connections"] = 0;
            else
                status.Add("connections", 0);


            foreach (string _channel in many_channels)
            {
                ParameterizedThreadStart pts = new ParameterizedThreadStart(run);
                Thread t = new Thread(pts);
                t.Start(_channel);
                if (threads.ContainsKey(_channel))
                    threads[_channel] = t;
                else
                    threads.Add(_channel, t);
                try
                {
                    Thread.Sleep(1000);
                }
                catch (ThreadInterruptedException e)
                {
                    Debug.WriteLine(e.Message);
                }
            }
        }
        public static void run(object _channel)
        {
            //Subscribe messages
            pubnub.Procedure Receiver = delegate(object message)
            {
                int sent = Convert.ToInt32(status["sent"]);
                int received = Convert.ToInt32(status["received"]);               
                test(received <= sent, "many sends");
                status.Remove("received");
                status.Add("received", received + 1);
                Dictionary<String, Object> args = new Dictionary<String, Object>(1);
                args.Add("channel", _channel);
                _pubnub.Unsubscribe(args);
                Dictionary<String, string> argsHistory = new Dictionary<String, string>(2);
                argsHistory.Add("channel", _channel.ToString());
                argsHistory.Add("limit", "2");

                List<object> response = _pubnub.History(argsHistory);
                test(response != null && response.Count > 0, "history");
                Debug.WriteLine("received count " + Convert.ToInt32(status["received"]));
                if (Convert.ToInt32(status["received"]) == many_channels.Count)
                {
                    runthroughs += 1;
                    if (runthroughs < planned_tests)
                    {
                        UnitTestAll(_pubnub);
                    }
                }
                return true;
            };

            pubnub.Procedure ConnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                int connections = Convert.ToInt32(status["connections"]);
                status.Remove("connections");
                status.Add("connections", connections + 1);
                publishAndSetStatus(_channel.ToString(), Message);
                return true;
            };
            pubnub.Procedure DisconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ReconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ErrorCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            Dictionary<String, Object> argsSub = new Dictionary<String, Object>(6);
            argsSub.Add("channel", _channel.ToString());
            argsSub.Add("callback", Receiver); // callback to get response
            argsSub.Add("connect_cb", ConnectCallback);        // callback to get connect event
            argsSub.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
            argsSub.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
            argsSub.Add("error_cb", ErrorCallback);            // callback to get error event

            // Listen for Messages (Subscribe)
            _pubnub.Subscribe(argsSub);
        }
        public static void publishAndSetStatus(string channel, object message)
        {
            // Publish message in array format            
            Dictionary<string, object> args = new Dictionary<string, object>(2);

            args.Add("channel", channel);
            args.Add("message", message);

            // publish Response
            List<object> info = _pubnub.Publish(args);
            int sent = Convert.ToInt32(status["sent"]);
            status.Remove("sent");
            status.Add("sent", sent + 1);
            test(info != null, "publish complete");
            test(info != null && info.Count > 2, "publish responce");

            if (info == null || info.Count <= 0)
            {
                delivery_retries += 1;
                if (max_retries > delivery_retries)
                {
                    publishAndSetStatus(channel, message);
                }
            }
        }
    }
}