using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PubNub_Messaging
{
    internal static class Here_Now_Example
    {
        public static void Main()
        {
            Here_Now_Demo();
            Console.ReadLine();
        }

        internal static void Here_Now_Demo()
        {
            Pubnub pubnub = new Pubnub(
                        "demo",
                        "demo",
                        "",
                        "",
                        false);

            string channel = "my/channel";

            Console.WriteLine("Here_Now_Example");

            pubnub.here_now<string>(channel, DisplayReturnMessage);

        }

        static void DisplayReturnMessage(string result )
        {
            Console.WriteLine(result);
        }

    }
}
