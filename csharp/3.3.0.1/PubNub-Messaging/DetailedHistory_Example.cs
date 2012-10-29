using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PubNub_Messaging
{
    internal static class DetailedHistory_Example
    {
        internal static void DetailedHistoryCountDemo()
        {
            Pubnub pubnub = new Pubnub(
                        "demo",
                        "demo",
                        "",
                        "",
                        false);
            
            string channel = "my_channel";

            //Console.WriteLine("Detailed History Count Demo");
            //pubnub.detailedHistory(channel, 100, DisplayDetailedHistory);

            //Console.WriteLine("Detailed History Count and reverse Demo");
            //pubnub.detailedHistory(channel, -1, -1, 100, true, DisplayDetailedHistory);

            //Console.WriteLine("Detailed History with start and end");
            //pubnub.detailedHistory(channel, 13499635513028988, 13499836911845528, 200, true, DisplayDetailedHistory);

            //Console.WriteLine("Detailed History with start");
            //pubnub.detailedHistory(channel, 13499635513028988, -1, 100, true, DisplayDetailedHistory);

            Console.WriteLine("Detailed History with end");
            pubnub.detailedHistory(channel, -1, 13499836911845528, 100, true, DisplayDetailedHistory);
        }

        static void DisplayDetailedHistory(object result)
        {
            try
            {
                IList<object> msg = result as IList<object>;
                if (msg != null && msg.Count > 0)
                {
                    object[] history = msg[0] as object[];
                    if (history != null && history.Length > 0)
                    {
                        Console.WriteLine(string.Format("Total history records = {0}", history.Length));
                        foreach (object item in history)
                        {
                            if (!item.GetType().IsGenericType)
                            {
                                Console.WriteLine(item.ToString());
                            }
                            else if ((item.GetType().IsGenericType) && (item.GetType().Name == typeof(Dictionary<,>).Name))
                            {
                                Dictionary<string, object> itemList = (Dictionary<string, object>)item;
                                foreach (KeyValuePair<string, object> pair in itemList)
                                {
                                    Console.WriteLine(string.Format("Key = {0}; Value = {1}", pair.Key, pair.Value));
                                }
                            }
                            else
                            {
                                Console.WriteLine(string.Format("Unhandled type {0}",item.ToString()));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }
    }
}
