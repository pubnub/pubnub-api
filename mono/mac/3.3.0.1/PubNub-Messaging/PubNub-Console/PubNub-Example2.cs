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
        static public bool deliveryStatus = false;
        static public string channel = "testchannel";
        static public string message = "Pubnub API Usage Example - Publish";
        static public Dictionary<long, string> inputs = new Dictionary<long, string>();
        static public object objResponse = null;

        public static void TestEncryptedDetailedHistoryParams()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "enigma",
                    false);
            // Context setup for Detailed Histor
            //pubnub.CIPHER_KEY = "enigma";
            int total_msg = 10;
            long starttime = Timestamp(pubnub);
            
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

            long midtime = Timestamp(pubnub);
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


            long endtime = Timestamp(pubnub);

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

        public static long Timestamp (Pubnub pubnub)
        {
            deliveryStatus = false;

            pubnub.time(DisplayReturnMessage);
            while (!deliveryStatus) ;
            string strResponse = "";

            IList<object> fields = objResponse as IList<object>;
            return Convert.ToInt64(fields[0].ToString());
        }

        public static void TestUnencryptedHistory()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            string channel = "testchannel";
            //pubnub.CIPHER_KEY = "";

            deliveryStatus = false;
            string message = "Pubnub API Usage Example - Publish";


            pubnub.publish(channel, message, DisplayReturnMessage);
            while (!deliveryStatus) ;
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e) {
                if (e.PropertyName == "History")
                {
                    Console.WriteLine("\n*********** History Messages *********** ");
                    deliveryStatus = true;
                }
            };
            pubnub.history(channel, 1);
            
            deliveryStatus = false;

            while (!deliveryStatus) ;
			Console.WriteLine("\n*********** Publish *********** ");
            if (pubnub.History[0].Equals (null)) {
                Console.WriteLine("Null response");
            }
            else
            {
                Console.WriteLine(pubnub.History[0].ToString());
            }
        }

        public static void TestEncryptedHistory()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "enigma",
                    false);
            string channel = "testchannel";

            deliveryStatus = false;
            string message = "Pubnub API Usage Example - Publish";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "History")
                {
                    Console.WriteLine("\n*********** History Messages *********** ");
                    deliveryStatus = true;
                }
            };
            deliveryStatus = false;
            pubnub.publish(channel, message, DisplayReturnMessage);
            while (!deliveryStatus) ;

            deliveryStatus = false;
            pubnub.history(channel, 1);
            while (!deliveryStatus) ;
            if (pubnub.History[0].Equals (null)) {
                Console.WriteLine("Null response");
            }
            else
            {
                Console.WriteLine(pubnub.History[0].ToString());
            }
        }

        public static void TestUnencryptedDetailedHistory()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            string channel = "testchannel";
            //pubnub.CIPHER_KEY = "";
            int total_msg = 10;
            long starttime = Timestamp(pubnub);
            Dictionary<long, string> inputs = new Dictionary<long,string>();
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

            long midtime = Timestamp(pubnub);
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

            
            long endtime = Timestamp(pubnub);
            while (!deliveryStatus) ;

            deliveryStatus = false;
            pubnub.detailedHistory(channel, total_msg, DisplayReturnMessage);
            deliveryStatus = false;
            while (!deliveryStatus) ;

            Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");

            string strResponse = "";
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields =objResponse as IList<object>;
                int j = 0;
                foreach (object item in fields)
                {
                    strResponse = item.ToString();
                    Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
                    if(j<total_msg)
                        Console.WriteLine(strResponse);
                    j++;
                }                
            }  
        }

        public static void TestEncryptedDetailedHistory()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "enigma",
                    false);
            string channel = "testchannel";
            //pubnub.CIPHER_KEY = "enigma";

            int total_msg = 10;
            long starttime = Timestamp(pubnub);
            Dictionary<long, string> inputs = new Dictionary<long, string>();
            for (int i = 0; i < total_msg / 2; i++)
            {
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                while (!deliveryStatus) ;
                //long t = Timestamp();
                //inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long midtime = Timestamp(pubnub);
            for (int i = total_msg / 2; i < total_msg; i++)
            {
                string msg = i.ToString();
                pubnub.publish(channel, msg, DisplayReturnMessage);
                while (!deliveryStatus) ;
                //long t = Timestamp();
                //inputs.Add(t, msg);
                Console.WriteLine("Message # " + i.ToString() + " published");
            }

            long endtime = Timestamp(pubnub);
            while (!deliveryStatus) ;

            

            pubnub.detailedHistory(channel, total_msg, DisplayReturnMessage);
            deliveryStatus = false;
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
            string strResponse = "";
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields = objResponse as IList<object>;
                int j = 0;
                foreach (object item in fields)
                {
                    strResponse = item.ToString();
                    Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
                    if(j<total_msg)
                        Console.WriteLine(j.ToString(), strResponse);
                    j++;
                }                
            }  
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        }

        public static void TestUnencryptedDetailedHistoryParams()
        {
           Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            string channel = "testchannel";

            int total_msg = 10;
            long starttime = Timestamp(pubnub);
            
            
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

            long midtime = Timestamp(pubnub);
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


            long endtime = Timestamp(pubnub);

            deliveryStatus = false;

            Console.WriteLine("DetailedHistory with start & end");
            pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, DisplayReturnMessage);
            while (!deliveryStatus) ;
            
            Console.WriteLine("DetailedHistory with start & reverse = true");
            string strResponse = "";
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields = objResponse as IList<object>;
                int j = 0;
                foreach (object item in fields)
                {
                    strResponse = item.ToString();
                    Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
                    if(j<total_msg/2)
                        Console.WriteLine(j.ToString(), strResponse);
                    j++;
                }                
            }  
            
            deliveryStatus = false;
            pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, DisplayReturnMessage);
            while (!deliveryStatus) ;
            
            Console.WriteLine("DetailedHistory with start & reverse = false");
            strResponse = "";
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields = objResponse as IList<object>;
                int j = total_msg / 2;
                foreach (object item in fields)
                {
                    strResponse = item.ToString();
                    Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
                    if(j<total_msg)
                        Console.WriteLine(j.ToString(), strResponse);
                    j++;
                }                
            }  

            
            deliveryStatus = false;
            pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
            strResponse = "";
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields = objResponse as IList<object>;
                int j = 0;
                foreach (object item in fields)
                {
                    strResponse = item.ToString();
                    Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
                    if(j<total_msg/2)
                        Console.WriteLine(j.ToString(), strResponse);
                    j++;
                }                
            }  
        }

        public static void BasicEncryptionDecryptionTests ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");

            string enc = pc.encrypt("Pubnub Messaging API 1");
            Console.WriteLine ("Pubnub Messaging API 1 = " + enc);
            Console.WriteLine ("dec = " + pc.decrypt(enc));

            enc = pc.encrypt("yay!");
            Console.WriteLine ("yay = " + enc);
            Console.WriteLine ("dec = " + pc.decrypt(enc));

            Console.WriteLine ("Wi24KS4pcTzvyuGOHubiXg==: = " + pc.decrypt("Wi24KS4pcTzvyuGOHubiXg=="));
            Console.WriteLine ("f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=: = " + pc.decrypt("f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54="));
            Console.WriteLine ("f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=: = " + pc.decrypt("f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0="));
            Console.WriteLine ("zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF = " + pc.decrypt("zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF"));
            Console.WriteLine ("GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g= = " + pc.decrypt("GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g="));

            Console.WriteLine ("IDjZE9BHSjcX67RddfCYYg== = " + pc.decrypt("IDjZE9BHSjcX67RddfCYYg=="));
            Console.WriteLine ("Ns4TB41JjT2NCXaGLWSPAQ== = " + pc.decrypt("Ns4TB41JjT2NCXaGLWSPAQ=="));

            Console.WriteLine ("+BY5/miAA8aeuhVl4d13Kg== = " + pc.decrypt("+BY5/miAA8aeuhVl4d13Kg=="));

            Console.WriteLine ("Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE= = " + pc.decrypt("Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE="));
            Console.WriteLine ("q/xJqqN6qbiZMXYmiQC1Fw==: = " + pc.decrypt("q/xJqqN6qbiZMXYmiQC1Fw=="));
        }


        public static void Publish_Example()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";
            string message = "Pubnub API Usage Example";

            deliveryStatus = false;

            pubnub.publish(channel, message, DisplayReturnMessage);
            //wait till the response is received from the server
            while (!deliveryStatus) ;
            IList<object> fields = objResponse as IList<object>;
            string strSent = fields[1].ToString();
            string strOne = fields[0].ToString();
			Console.WriteLine("Sent: " + strSent);
			Console.WriteLine("One: " + strOne);
        }
        
        public static void DetailedHistory_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            string channel = "testchannel";
            //pubnub.CIPHER_KEY = "";
            string msg = "Test Message";
            deliveryStatus = false;
            pubnub.publish(channel, msg, DisplayReturnMessage);
            while (!deliveryStatus) ;
 
            deliveryStatus = false;
            pubnub.detailedHistory(channel, 10, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
            
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields = objResponse as IList<object>;

                foreach (object item in fields)
                {
                    string strResponse = item.ToString();
                    Console.WriteLine(String.Format("resp:{0}", strResponse));
                    Console.WriteLine(strResponse);
                }          
            } 
        }

        public static void DetailedHistory_Decrypted_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "enigma",
                    false);
            string channel = "testchannel";
            //pubnub.CIPHER_KEY = "enigma";
            string msg = "Test Message";

            deliveryStatus = false;
            pubnub.publish(channel, msg, DisplayReturnMessage);
            while (!deliveryStatus) ;

            deliveryStatus = false;
            pubnub.detailedHistory(channel, 1, DisplayReturnMessage);
            while (!deliveryStatus) ;
            Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
            
            if (objResponse.Equals(null))
            {
              Console.WriteLine("Null response");
            } 
            else
            {
                IList<object> fields = objResponse as IList<object>;
                Console.WriteLine("fields[0]: " + fields[0]);
                Console.WriteLine("fields[1]: " + fields[1]);
                //Assert.AreEqual(fields[0], msg);           
            }  

        }

        static void Timestamp_Example()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            
            string strResponse = "";
            deliveryStatus = false;

            pubnub.time(DisplayReturnMessage);
            while (!deliveryStatus) ;

            IList<object> fields = objResponse as IList<object>;
            strResponse = fields[0].ToString();
            Console.WriteLine(strResponse);
            //Assert.AreNotEqual("0",strResponse);
        }

        public static void Subscribe_Example ()
		{
			Pubnub pubnub = new Pubnub (
                   "demo",
                   "demo",
                   "",
                   "",
                   false);
			string channel = "hello_world";

			deliveryStatus = false;

			pubnub.subscribe (channel, DisplayReturnMessage); 

			pubnub.publish (channel, "Test Message", DisplayReturnMessage);
            
			bool bStop = false;
			while (!bStop) {
				if (objResponse != null) {
                    IList<object> fields = objResponse as IList<object>;

				    if (fields [0] != null)
					{
				 	    var myObjectArray = (from item in fields select item as object).ToArray ();
					    IEnumerable enumerable = myObjectArray [0] as IEnumerable;
					    if (enumerable != null) {
						    foreach (object element in enumerable) 
							{
							    Console.WriteLine ("Resp:" + element.ToString ());
								bStop = true;
						    }
					    }
				    }
				}
			}
        }

        public static void Presence_Example()
        {
			Pubnub pubnub = new Pubnub (
                   "demo",
                   "demo",
                   "",
                   "",
                   false);
			string channel = "hello_world";

			deliveryStatus = false;

			pubnub.presence (channel, DisplayReturnMessage); 
			Pubnub pubnub2 = new Pubnub (
                   "demo",
                   "demo",
                   "",
                   "",
                   false);

			pubnub2.subscribe (channel, DisplayReturnMessage);
            
			bool bStop = false;
			while (!bStop) {
				if (objResponse != null) {
                    IList<object> fields = objResponse as IList<object>;

				    if (fields [0] != null)
					{
				 	    var myObjectArray = (from item in fields select item as object).ToArray ();
					    IEnumerable enumerable = myObjectArray [0] as IEnumerable;
					    if (enumerable != null) {
						    foreach (object element in enumerable) 
							{
							    Console.WriteLine ("Resp:" + element.ToString ());
								//bStop = true;
						    }
					    }
				    }
				}
			}

        }

        public static void HereNow_Example()
        {
            Pubnub pubnub = new Pubnub(
               "demo",
               "demo",
               "",
               "",
               false
           );
            string channel = "hello_world";

            deliveryStatus = false;

            pubnub.here_now(channel, DisplayReturnMessage);
            while (!deliveryStatus) ;

            string strResponse = "";
            if (objResponse.Equals (null)) {
                Console.WriteLine("Null response");
            }
            else
            {
                IList<object> fields =objResponse as IList<object>;
                foreach(object lst in fields)
                {
                    strResponse = lst.ToString();
                    Console.WriteLine(strResponse);
                }
                Dictionary<string, object> message = (Dictionary<string, object>)fields[0];
                foreach(KeyValuePair<String, object> entry in message)
                {
                    Console.WriteLine("value:" + entry.Value + "  " + "key:" + entry.Key);
                }

                object[] objUuid = (object[])message["uuids"];
                foreach (object obj in objUuid)
                {
                    Console.WriteLine(obj.ToString()); 
                }
            }
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
            objResponse = result;
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

