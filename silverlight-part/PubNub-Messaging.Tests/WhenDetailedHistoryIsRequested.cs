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
            string channel = "my_channel";

            pubnub.detailedHistory(channel, 100, DisplayDetailedHistory);            
        }

        void DisplayDetailedHistory(object result)
        {
            Assert.IsNotNull(result);
        }

        //static void Pubnub_PropertyChanged(object sender, PropertyChangedEventArgs e)
        //{
        //    Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).ReturnMessage);
        //    if (e.PropertyName != "DetailedHistory")
        //    {
        //        Assert.IsNotNull(_message["text"]);
        //    }
        //    else
        //    {
        //        Assert.AreEqual("", _message["uuid"]);
        //    }
        //}
    }
}
