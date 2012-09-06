using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenDetailedHistoryIsRequested
    {
        [TestMethod]
        public void ItShouldReturnDetailedHistory()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);
            pubnub.detailedHistory(channel, 100);            
        }

        static void Pubnub_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).ReturnMessage);
            if (e.PropertyName != "DetailedHistory")
            {
                Assert.IsNotNull(_message["text"]);
            }
            else
            {
                Assert.AreEqual("", _message["uuid"]);
            }
        }
    }
}
