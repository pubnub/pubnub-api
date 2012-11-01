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
    public class WhenGetRequestServerTime
    {
        [TestMethod]
        public void ThenItShouldReturnTimeStamp()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            
            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            pubnub.time();
        }

        static void Pubnub_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            //Assert.AreNotEqual("0", ((Pubnub)sender).Time[0].ToString());
        }
    }
}
