using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PubNub_Messaging
{
    internal static class Presence_Example
    {
        internal static void PresenceDemo()
        {
            Pubnub pubnub = new Pubnub(
                        "demo",
                        "demo",
                        "",
                        "",
                        false);
            
            string channel = "my_channel";

            Console.WriteLine("Presence_Example");

            pubnub.presence(channel, DisplayReturnMessage);

            bool pre_unsub = false;
            while (!pre_unsub)
            {
                Console.WriteLine("Enter y for Presence-Unsub; x to EXIT presence loop");
                string userchoice = Console.ReadLine();
                if (userchoice.ToLower() == "y")
                {
                    Console.WriteLine("PresenceUnsubscribe_Example");
                    pubnub.presence_unsubscribe(channel, DisplayReturnMessage);

                    pre_unsub = true;
                }
                else if (userchoice.ToLower() == "x")
                {
                    pre_unsub = true;
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
        //                            Console.WriteLine(string.Format("[{0}][{1}] = {2}", index, itemIndex, itemList[itemIndex].ToString()));
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
        //                    Console.WriteLine(string.Format("[{0}][{1}] = {2}",index, pair.Key, pair.Value));
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
