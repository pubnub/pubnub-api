using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PubnubSilverlight.Core
{
    internal  static partial class Publish_Example
    {
        internal static void PublishDemo()
        {
            Pubnub pubnub = new Pubnub(
                        "demo",
                        "demo",
                        "",
                        "",
                        false);

            string channel = "my_channel";
            
            Console.WriteLine("Publish_Example");
            
            bool exitFlag = false;
            while (!exitFlag)
            {
                Console.WriteLine("Enter the message for publish. To exit loop, enter QUIT");
                string userinput = Console.ReadLine();
                if (userinput.ToLower() == "quit")
                {
                    exitFlag = true;
                }
                else
                {
                    pubnub.publish(channel, userinput, DisplayReturnMessage);
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

        //static void DisplayPublishReturnMessage(object result)
        //{
        //    List<object> message = result as List<object>;

        //    if (message != null && message.Count >= 2)
        //    {
        //        Console.WriteLine(string.Format("[{0}, {1}, {2}]", message[0].ToString(),message[1].ToString(),message[2].ToString()));
        //    }
        //    else
        //    {
        //        Console.WriteLine("result is not List<object>");
        //    }
        //}
    }
}
