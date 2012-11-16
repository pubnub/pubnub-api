using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PubNub_Messaging
{
    internal static class Subscribe_Example
    {
        internal static void SubscribeDemo()
        {
            Pubnub pubnub = new Pubnub(
                        "demo",
                        "demo",
                        "",
                        "",
                        false);
            
            string channel = "my_channel";

            Console.WriteLine("Subscribe_Example");

            pubnub.subscribe(channel, DisplayReturnMessage);
            
            bool userexit = false;
            while (!userexit)
            {
                Console.WriteLine("For Unsubscribe");
                Console.WriteLine("Enter Y for UNSUBSCRIBE or ENTER X to EXIT subscribe loop");
                string userinput = Console.ReadLine();
                if (userinput.ToLower() == "y")
                {
                    pubnub.unsubscribe(channel, DisplayReturnMessage);
                    userexit = true;
                }
                else if (userinput.ToLower() == "x")
                {
                    userexit = true;
                }
            } 
        }

        internal static void SecureSubscribeDemo()
        {
            Pubnub pubnub = new Pubnub(
                        "",
                        "demo",
                        "",
                        "pandu",
                        false);

            string channel = "my_channel";

            Console.WriteLine("Secure_Subscribe_Example");

            pubnub.subscribe(channel, DisplayReturnMessage);

            //Console.WriteLine("second channel");
            //pubnub.subscribe("second_channel", DisplaySubscribeReturnMessage1);

            //Console.WriteLine("third channel");
            //pubnub.subscribe("third_channel", DisplaySubscribeReturnMessage1);

            //Console.WriteLine("fourth channel");
            //pubnub.subscribe("fourth_channel", DisplaySubscribeReturnMessage1);

            //string channelNum = "";
            //do
            //{
            //    Console.WriteLine("For Unsub");
            //    Console.WriteLine("Enter 1 for my_channel, 2 for second_channel, 3 for third_channel, 4 for fourth channel, x for EXIT");
            //    channelNum = Console.ReadLine();
            //    if (channelNum == "1")
            //    {
            //        pubnub.unsubscribe(channel, DisplaySubscribeReturnMessage1);
            //    }
            //    else if (channelNum == "2")
            //    {
            //        pubnub.unsubscribe("second_channel", DisplaySubscribeReturnMessage1);
            //    }
            //    else if (channelNum == "3")
            //    {
            //        pubnub.unsubscribe("third_channel", DisplaySubscribeReturnMessage1);
            //    }
            //    else if (channelNum == "4")
            //    {
            //        pubnub.unsubscribe("fourth_channel", DisplaySubscribeReturnMessage1);
            //    }
            //} while (channelNum.ToLower() != "x");

            //Console.WriteLine("Please wait...");
            //Console.ReadLine();
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

        }


        //static void DisplayReturnMessage(object result)
        //{
        //    IList<object> message = result as IList<object>;

        //    if (message != null && message.Count >= 2)
        //    {
        //        for (int index = 0; index < message.Count; index++)
        //        {
        //            if (!message[index].GetType().IsGenericType)
        //            {
        //                if (message[index] is object[])
        //                {
        //                    object[] itemList = (object[])message[index];
        //                    for (int itemIndex = 0; itemIndex < itemList.Length; itemIndex++)
        //                    {
        //                        if (!itemList[itemIndex].GetType().IsGenericType)
        //                        {
        //                            if (itemList[itemIndex].GetType().IsPrimitive)
        //                            {
        //                                Console.WriteLine(string.Format("[{0}][{1}] = {2}", index, itemIndex, itemList[itemIndex].ToString()));
        //                            }
        //                            else
        //                            {
        //                                if (itemList[itemIndex] is object[])
        //                                {
        //                                    object[] subitemList = (object[])itemList[itemIndex];
        //                                    for (int subitemIndex = 0; subitemIndex < subitemList.Length; subitemIndex++)
        //                                    {
        //                                        Console.WriteLine(string.Format("[{0}][{1}][{2}] = {3}", index, itemIndex, subitemIndex, subitemList[subitemIndex].ToString()));
        //                                    }
        //                                }
                                        
        //                            }
        //                        }
        //                        else if ((itemList[itemIndex].GetType().IsGenericType) && (itemList[itemIndex].GetType().Name == typeof(Dictionary<,>).Name))
        //                        {
        //                            Dictionary<string, object> subitemList = (Dictionary<string, object>)itemList[itemIndex];
        //                            foreach (KeyValuePair<string, object> pair in subitemList)
        //                            {
        //                                Console.WriteLine(string.Format("[{0}][{1}] = {2}", index, pair.Key, pair.Value));
        //                            }
        //                        }
        //                    }
        //                }
        //                else
        //                {
        //                    Console.WriteLine(string.Format("[{0}] = {1}", index, message[index].ToString()));
        //                }
        //            }
        //            else if ((message[index].GetType().IsGenericType) && (message[index].GetType().Name == typeof(Dictionary<,>).Name))
        //            {
        //                Dictionary<string, object> itemList = (Dictionary<string, object>)message[index];
        //                foreach (KeyValuePair<string, object> pair in itemList)
        //                {
        //                    Console.WriteLine(string.Format("[{0}][{1}] = {2}", index, pair.Key, pair.Value));
        //                }
        //            }
        //        }
        //    }
        //    else
        //    {
        //        Console.WriteLine("result is not List<object>");
        //    }
        //}

        


    }
}
