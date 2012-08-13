using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace PubNub_Messaging
{
    public class Pubnub_Example
    {
        static public void Main()
        {
            Publish_Example();
            History_Example();
            Timestamp_Example();
            Subscribe_Example();
            Presence_Example();
            HereNow_Example();

            Console.ReadKey();
        }
        static void Publish_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    false);
            string channel = "my/channel";
            string message = "Pubnub API Usage Example - Publish";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Publish")
                {
                    Console.WriteLine(
                        "Publish Success: " + ((Pubnub)sender).Publish[0].ToString() +
                        "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString()
                        );
                }
            };
            pubnub.publish(channel, message);
        }
        static void History_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    false);
            string channel = "my/channel";
            
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "History")
                {
                    foreach (object history_message in ((Pubnub)sender).History)
                    {
                        Console.WriteLine("History Message: ");
                        Dictionary<string, object> _messageHistory = (Dictionary<string, object>)(history_message);
                        Console.WriteLine(_messageHistory["text"]);
                    }
                }
            };
            pubnub.history(channel, 10);
        }
        static void Timestamp_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    false);
            
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Time")
                {
                    Console.WriteLine("Time:  " + ((Pubnub)sender).Time[0].ToString());
                }
            };
            pubnub.time();
        }
        static void Subscribe_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    false);
            string channel = "my/channel";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "ReturnMessage")
                {
                    Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).ReturnMessage);
                    Console.WriteLine("Received Message -> '" + _message["text"] + "'");
                }
            };
            pubnub.subscribe(channel);
        }

        static void Presence_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    false);
            string channel = "my/channel";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "ReturnMessage")
                {
                    Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).ReturnMessage);
                    Console.WriteLine("Received Message -> '" + _message["text"] + "'");
                }
            };
            pubnub.presence(channel);
        }

        static void HereNow_Example()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    false);
            //string channel = "my/channel";
            string channel = "hello_world";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "Here_Now")
                {
                    Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).Here_Now[0]);
                    foreach (object uuid in (object[])_message["uuids"])
                    {
                        Console.WriteLine("UUID: " + uuid.ToString());
                    }
                    Console.WriteLine("Occupancy: " + _message["occupancy"].ToString());
                    Console.WriteLine("Here_Now feature is enabled.");
                }
            };
            pubnub.here_now(channel);
        }
    }
}
