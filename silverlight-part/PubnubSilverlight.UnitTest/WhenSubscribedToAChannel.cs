using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using PubnubSilverlight.Core;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenSubscribedToAChannel
    {
        [TestMethod]
        public void ThenItShouldReturnReceivedMessage()
        {
            string status = "";
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                //if (e.PropertyName == "ReturnMessage")
                //{
                //    Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).ReturnMessage);
                //    Console.WriteLine("Received Message -> '" + _message["text"] + "'");
                //    status = _message["text"].ToString();
                //    Assert.AreEqual("assert", status);
                //}
            };
            pubnub.subscribe(channel);

        }
    }
}
