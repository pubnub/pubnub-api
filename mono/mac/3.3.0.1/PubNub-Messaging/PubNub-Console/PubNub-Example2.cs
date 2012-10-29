using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using PubNubLib;
using System.Collections;

namespace PubNubConsole
{
    public class Pubnub_Example2
    {
        static public Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);

        static public bool deliveryStatus = false;
        static public string channel = "my_channel";
        static public string message = "Pubnub API Usage Example - Publish";
		static public Dictionary<long, string> inputs = new Dictionary<long, string>();

        public static void TestEncryptedDetailedHistoryParams()
        {
            // Context setup for Detailed Histor
            pubnub.CIPHER_KEY = "enigma";
            int total_msg = 10;
            long starttime = Timestamp();
            
            
            for (int i = 0; i < total_msg / 2; i++)
            {
				deliveryStatus = false;
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
				while (!deliveryStatus) ;
                //long t = Timestamp();
                //inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long midtime = Timestamp();
            for (int i = total_msg / 2; i < total_msg; i++)
            {
				deliveryStatus = false;
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
				while (!deliveryStatus) ;
                //long t = Timestamp();
                //inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }


            long endtime = Timestamp();

            deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "DetailedHistory")
                {
                    Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
                    /*foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
                    {
                        Console.WriteLine(msg_org.ToString());
                    }*/
                    deliveryStatus = true;
                }
            };
            Console.WriteLine("DetailedHistory with start & end");
            pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("DetailedHistory with start & reverse = true");
            deliveryStatus = false;
            pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("DetailedHistory with start & reverse = false");
            deliveryStatus = false;
            pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
        }


        public static long Timestamp()
        {
            deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Time")
                {
                    deliveryStatus = true;
                }
            };
            pubnub.time();
            while (!deliveryStatus) ;
            return Convert.ToInt64(pubnub.Time[0].ToString());
        }

        public static void TestUnencryptedHistory()
        {
            pubnub.CIPHER_KEY = "";
			deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                /*if (e.PropertyName == "Publish")
                {
                    Console.WriteLine("\n*********** Publish Messages *********** ");
                    Console.WriteLine(
                        "Publish Success: " + ((Pubnub)sender).Publish[0].ToString() +
                        "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString()
                        );
                }*/

                if (e.PropertyName == "History")
                {
                    Console.WriteLine("\n*********** History Messages *********** ");
                    MessageFeeder(((Pubnub)sender).History);
                }
            };
            pubnub.publish(channel, message, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Publish *********** ");
            pubnub.history(channel, 1);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** History *********** ");
        }

        public static void TestEncryptedHistory()
        {
            pubnub.CIPHER_KEY = "enigma";
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                /*if (e.PropertyName == "Publish")
                {
                    Console.WriteLine("\n*********** Publish Messages *********** ");
                    Console.WriteLine(
                        "Publish Success: " + ((Pubnub)sender).Publish[0].ToString() +
                        "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString()
                        );
                }*/

                if (e.PropertyName == "History")
                {
                    Console.WriteLine("\n*********** History Messages *********** ");
                    MessageFeeder(((Pubnub)sender).History);
                }
            };
			deliveryStatus = false;
            pubnub.publish(channel, message, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Publish *********** ");
			deliveryStatus = false;
            pubnub.history(channel, 1);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** History *********** ");
        }

        public static void TestUnencryptedDetailedHistory()
        {
            // Context setup for Detailed History
            pubnub.CIPHER_KEY = "";
            int total_msg = 10;
            long starttime = Timestamp();
            Dictionary<long, string> inputs = new Dictionary<long,string>();
            for (int i = 0; i < total_msg / 2; i++)
            {
				deliveryStatus = false;
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                long t = Timestamp();
                inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long midtime = Timestamp();
            for (int i = total_msg / 2; i < total_msg; i++)
            {
				deliveryStatus = false;
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                long t = Timestamp();
                inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long endtime = Timestamp();

            deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                /*if (e.PropertyName == "DetailedHistory")
                {
                    Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
					//modified object[] to List<object>
                    foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
                    {
                        Console.WriteLine(msg_org.ToString());
                    }
                    deliveryStatus = true;
                }*/
            };
            pubnub.detailedHistory(channel, total_msg, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
        }

        public static void TestEncryptedDetailedHistory()
        {
            // Context setup for Detailed History
            pubnub.CIPHER_KEY = "enigma";
            int total_msg = 10;
            long starttime = Timestamp();
            Dictionary<long, string> inputs = new Dictionary<long, string>();
            for (int i = 0; i < total_msg / 2; i++)
            {
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                long t = Timestamp();
                inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long midtime = Timestamp();
            for (int i = total_msg / 2; i < total_msg; i++)
            {
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                long t = Timestamp();
                inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long endtime = Timestamp();

            deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                /*if (e.PropertyName == "DetailedHistory")
                {
                    Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
                    foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
                    {
                        Console.WriteLine(msg_org.ToString());
                    }
                    deliveryStatus = true;
                }*/
            };
            pubnub.detailedHistory(channel, total_msg, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        }

        public static void TestUnencryptedDetailedHistoryParams()
        {
            // Context setup for Detailed History
            pubnub.CIPHER_KEY = "";
            int total_msg = 10;
            long starttime = Timestamp();
            Dictionary<long, string> inputs = new Dictionary<long, string>();
            for (int i = 0; i < total_msg / 2; i++)
            {
				deliveryStatus = false;
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                long t = Timestamp();
                inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long midtime = Timestamp();
            for (int i = total_msg / 2; i < total_msg; i++)
            {
				deliveryStatus = false;
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                long t = Timestamp();
                inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long endtime = Timestamp();

            deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "DetailedHistory")
                {
                    Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
					//modified object[] to List<object>
                    /*foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
                    {
                        Console.WriteLine(msg_org.ToString());
                    }
                    deliveryStatus = true;*/
                }
            };
            Console.WriteLine("DetailedHistory with start & end");
            pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("DetailedHistory with start & reverse = true");
            deliveryStatus = false;
            pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("DetailedHistory with start & reverse = false");
            deliveryStatus = false;
            pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
        }

        public static void BasicEncryptionDecryptionTests ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");

            string enc = pc.EncryptOrDecrypt(true, "Pubnub Messaging API 1");
            Console.WriteLine ("Pubnub Messaging API 1 = " + enc);
            Console.WriteLine ("dec = " + pc.EncryptOrDecrypt(false, enc));

            enc = pc.EncryptOrDecrypt(true, "yay!");
            Console.WriteLine ("yay = " + enc);
            Console.WriteLine ("dec = " + pc.EncryptOrDecrypt(false, enc));

            Console.WriteLine ("Wi24KS4pcTzvyuGOHubiXg==: = " + pc.EncryptOrDecrypt(false, "Wi24KS4pcTzvyuGOHubiXg=="));
            Console.WriteLine ("f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=: = " + pc.EncryptOrDecrypt(false, "f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54="));
            Console.WriteLine ("f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=: = " + pc.EncryptOrDecrypt(false, "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0="));
            Console.WriteLine ("zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF = " + pc.EncryptOrDecrypt(false, "zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF"));
            Console.WriteLine ("GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g= = " + pc.EncryptOrDecrypt(false, "GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g="));

            Console.WriteLine ("IDjZE9BHSjcX67RddfCYYg== = " + pc.EncryptOrDecrypt(false, "IDjZE9BHSjcX67RddfCYYg=="));
            Console.WriteLine ("Ns4TB41JjT2NCXaGLWSPAQ== = " + pc.EncryptOrDecrypt(false, "Ns4TB41JjT2NCXaGLWSPAQ=="));

            Console.WriteLine ("+BY5/miAA8aeuhVl4d13Kg== = " + pc.EncryptOrDecrypt(false, "+BY5/miAA8aeuhVl4d13Kg=="));

            Console.WriteLine ("Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE= = " + pc.EncryptOrDecrypt(false, "Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE="));
            Console.WriteLine ("q/xJqqN6qbiZMXYmiQC1Fw==: = " + pc.EncryptOrDecrypt(false, "q/xJqqN6qbiZMXYmiQC1Fw=="));
        }


        public static void Publish_Example()
        {
            pubnub.CIPHER_KEY = "";
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Publish")
                {
                    /*Console.WriteLine("\n*********** Publish Messages *********** ");
                    Console.WriteLine(
                        "Publish Success: " + ((Pubnub)sender).Publish[0].ToString() +
                        "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString()
                        );*/
                }
            };
			deliveryStatus = false;
            pubnub.publish(channel, message, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Publish *********** ");
        }
        
        public static void DetailedHistory_Example()
        {
            pubnub.CIPHER_KEY = "";
            //int start = 
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "DetailedHistory")
                {
                    /*Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
                    MessageFeeder(((Pubnub)sender).DetailedHistory);
                    deliveryStatus = true;*/
                }
            };
			deliveryStatus = false;
            pubnub.detailedHistory(channel, 10, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        }

        public static void DetailedHistory_Decrypted_Example()
        {
            pubnub.CIPHER_KEY = "enigma";
            //int start = 
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "DetailedHistory")
                {
                    /*Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
                    MessageFeeder((List<object>)(((Pubnub)sender).DetailedHistory));
                    deliveryStatus = true;*/
                }
            };
			deliveryStatus = false;
            pubnub.detailedHistory(channel, 1, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        }

        static void Timestamp_Example()
        {
            pubnub.CIPHER_KEY = "";
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Time")
                {
                    Console.WriteLine("\n********** Timestamp Messages ********** ");
                    MessageFeeder(((Pubnub)sender).Time[0]);
                }
            };
            pubnub.time();
			deliveryStatus = false;
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Timestamp *********** ");
        }
        public static void Subscribe_Example()
        {
            pubnub.CIPHER_KEY = "";
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                /*if (e.PropertyName == "ReturnMessage")
                {
                    Console.WriteLine("\n********** Subscribe Messages ********** ");
                    MessageFeeder(((Pubnub)sender).ReturnMessage);
       			}
                //added Roger
                else if (e.PropertyName == "Subscribe")
                {
                    Console.WriteLine("\n********** Subscribe Messages ********** ");
                    MessageFeeder(((Pubnub)sender).Subscribe);
                }*/
            };
			deliveryStatus = false;
            pubnub.subscribe(channel, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Subscribe*********** ");
        }

        public static void Presence_Example()
        {
            pubnub.CIPHER_KEY = "";
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                /*if (e.PropertyName == "ReturnMessage")
                {
                    Console.WriteLine("\n********** Presence Messages ********** ");
                    MessageFeeder(((Pubnub)sender).ReturnMessage);
                }
                //added Roger
                else if (e.PropertyName == "Presence")
                {
                    Console.WriteLine("\n********** Presence Messages ********** ");
                    MessageFeeder(((Pubnub)sender).Presence);
                }*/
            };
			deliveryStatus = false;
            pubnub.presence(channel, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Presence *********** ");
        }

        public static void HereNow_Example()
        {
            pubnub.CIPHER_KEY = "";
			deliveryStatus = false;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Here_Now")
                {
                    Console.WriteLine("\n********** Here Now Messages *********** ");
                    /*Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).Here_Now[0]);
                    foreach (object uuid in (object[])_message["uuids"])
                    {
                        Console.WriteLine("UUID: " + uuid.ToString());
                    }
                    Console.WriteLine("Occupancy: " + _message["occupancy"].ToString());*/
                }
            };
			deliveryStatus = false;
            pubnub.here_now(channel, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** Here Now *********** ");
        }

        static void MessageFeeder(List<object> feed)
        {
            foreach (object message in feed)
            {
                try
                {
                    Dictionary<string, object> _messageHistory = (Dictionary<string, object>)(message);
                    Console.WriteLine("Key: " + _messageHistory.ElementAt(0).Key + " - Value: " + _messageHistory.ElementAt(0).Value);
                }
                catch
                {
                    Console.WriteLine(message.ToString());
                }
            }
        }
        static void MessageFeeder(object feed)
        {
            try
            {
                Dictionary<string, object> _message = (Dictionary<string, object>)(feed);
                for (int i = 0; i < _message.Count; i ++)
                    Console.WriteLine("Key: " + _message.ElementAt(i).Key + " - Value: " + _message.ElementAt(i).Value);
            }
            catch
            {
                try
                {
                    List<object> _message = (List<object>)feed;
                    for (int i = 0; i < _message.Count; i++)
                        Console.WriteLine(_message[i].ToString());
                }
                catch
                {
                    Console.WriteLine("Time: " + feed.ToString());
                }
                
            }
        }

 		static void DisplayReturnMessage(object result)
        {
            IList<object> message = result as IList<object>;

            if (message != null && message.Count >= 2)
            {
                for (int index = 0; index < message.Count; index++)
                {
                    ParseObject(message[index], 1);
                }
            }
            else
            {
                Console.WriteLine("unable to parse data");
            }
			deliveryStatus = true;
        }

        static void ParseObject(object result, int loop)
        {
            if (result is object[])
            {
                object[] arrResult = (object[])result;
                foreach (object item in arrResult)
                {
                    if (!item.GetType().IsGenericType)
                    {
                        if (!item.GetType().IsArray)
                        {
                            Console.WriteLine(item.ToString());
                        }
                        else
                        {
                            ParseObject(item, loop + 1);
                        }
                    }
                    else
                    {
                        ParseObject(item, loop + 1);
                    }
                }
            }
            else if (result.GetType().IsGenericType && (result.GetType().Name == typeof(Dictionary<,>).Name))
            {
                Dictionary<string, object> itemList = (Dictionary<string, object>)result;
                foreach (KeyValuePair<string, object> pair in itemList)
                {
                    Console.WriteLine(string.Format("key = {0}", pair.Key));
                    if (pair.Value is object[])
                    {
                        Console.WriteLine("value = ");
                        ParseObject(pair.Value, loop);
                    }
                    else
                    {
                        Console.WriteLine(string.Format("value = {0}", pair.Value));
                    }
                }
            }
            else
            {
                Console.WriteLine(result.ToString());
            }

        }		
	}
}

