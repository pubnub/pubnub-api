using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PubnubSilverlight.Core
{
    internal class PresenceUnsubscribe_Example
    {
        internal static void PresenceUnsubscribeDemo()
        {
            Pubnub pubnub = new Pubnub(
                        "demo",
                        "demo",
                        "",
                        "",
                        false);

            string channel = "my_channel";

            Console.WriteLine("PresenceUnsubscribe_Example");

            pubnub.presence_unsubscribe(channel, DisplayPresenceUnpresenceReturnMessage);

        }

        static void DisplayPresenceUnpresenceReturnMessage(object result)
        {
            IList<object> message = result as IList<object>;

            if (message != null && message.Count >= 2)
            {
                for(int index=0; index < message.Count; index++)
                {
                    Console.WriteLine(string.Format("[{0}] = {1}",index, message[index].ToString()));
                    object[] msg = message[0] as object[];
                    if (msg != null)
                    {
                        foreach (object item in msg)
                        {
                            if (item is Dictionary<string, object>)
                            {
                                Dictionary<string, object> itemList = (Dictionary<string, object>)item;
                                foreach (KeyValuePair<string, object> pair in itemList)
                                {
                                    Console.WriteLine(string.Format("Key = {0}; Value = {1}", pair.Key, pair.Value));
                                }
                            }
                            else if (item is object[])
                            {
                                object[] itemList = (object[])item;
                                foreach (string innerItem in itemList)
                                {
                                    Console.WriteLine(innerItem.ToString());
                                }
                            }
                            else
                            {
                                Console.WriteLine(item.ToString());
                            }
                        }
                    }
                }
                Console.WriteLine(string.Format("Channel = {0}", message[2].ToString()));

            }
            else
            {
                Console.WriteLine("result is not List<object>");
            }
        }

    }
}
