using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace PubNub_Messaging
{
    public class Pubnub_Example
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

        static public void Main()
        {
            Console.WriteLine("HINT: TO TEST RE-CONNECT AND CATCH-UP,");
            Console.WriteLine("      DISCONNECT YOUR MACHINE FROM NETWORK/INTERNET AND ");
            Console.WriteLine("      RE-CONNECT YOUR MACHINE AFTER SOMETIME.");
            Console.WriteLine();
            Console.WriteLine("      IF NO NETWORK BEFORE MAX RE-TRY CONNECT,");
            Console.WriteLine("      NETWORK ERROR MESSAGE WILL BE SENT");
            Console.WriteLine();

            Console.WriteLine("ENTER Channel Name");
            channel = Console.ReadLine();

            Console.WriteLine(string.Format("Channel = {0}",channel));
            Console.WriteLine();

            Console.WriteLine("ENTER 1 FOR Subscribe");
            Console.WriteLine("ENTER 2 FOR Publish");
            Console.WriteLine("ENTER 3 FOR Presence");
            Console.WriteLine("ENTER 4 FOR Detailed History");
            Console.WriteLine("ENTER 5 FOR Here_Now");
            Console.WriteLine("ENTER 6 FOR Unsubscribe");
            Console.WriteLine("ENTER 7 FOR Presence-Unsubscribe");
            Console.WriteLine("ENTER 8 FOR Time");
            Console.WriteLine("ENTER 0 FOR EXIT OR QUIT");

            bool exitFlag = false;

            Console.WriteLine("");
            while (!exitFlag)
            {
                string userinput = Console.ReadLine();
                switch (userinput)
                {
                    case "0":
                        exitFlag = true;
                        break;
                    case "1":
                        Console.WriteLine("Running subscribe()");
                        pubnub.subscribe(channel, DisplayReturnMessage);
                        break;
                    case "2":
                        Console.WriteLine("Running publish()");
                        Console.WriteLine("Enter the message for publish. To exit loop, enter QUIT");
                        string publishMsg = Console.ReadLine();
                        pubnub.publish(channel, publishMsg, DisplayReturnMessage);
                        break;
                    case "3":
                        Console.WriteLine("Running presence()");
                        pubnub.presence(channel, DisplayReturnMessage);
                        break;
                    case "4":
                        Console.WriteLine("Running detailed history()");
                        pubnub.detailedHistory(channel, 100, DisplayReturnMessage);
                        break;
                    case "5":
                        Console.WriteLine("Running Here_Now()");
                        pubnub.here_now(channel, DisplayReturnMessage);
                        break;
                    case "6":
                        Console.WriteLine("Running unsubscribe()");
                        pubnub.unsubscribe(channel, DisplayReturnMessage);
                        break;
                    case "7":
                        Console.WriteLine("Running presence-unsubscribe()");
                        pubnub.presence_unsubscribe(channel, DisplayReturnMessage);
                        break;
                    case "8":
                        Console.WriteLine("Running time()");
                        pubnub.time(DisplayReturnMessage);
                        break;
                    default:
                        Console.WriteLine("INVALID CHOICE.");
                        break;
                }
            }

            Console.WriteLine("\nPress any key to confirm exit.\n\n");
            Console.ReadLine();

        }

        static long Timestamp()
        {
            return 0;
            //deliveryStatus = false;
            //pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            //{
            //    if (e.PropertyName == "Time")
            //    {
            //        deliveryStatus = true;
            //    }
            //};
            //pubnub.time();
            //while (!deliveryStatus) ;
            //return Convert.ToInt64(pubnub.Time[0].ToString());
        }

        static void DisplayReturnMessage(object result)
        {
            IList<object> message = result as IList<object>;

            if (message != null && message.Count >= 1)
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
            else
            {
                Console.WriteLine(result.ToString());
            }

        }

    }
}
