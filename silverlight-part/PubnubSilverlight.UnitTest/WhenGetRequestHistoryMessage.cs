using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using PubnubSilverlight.Core;

namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenGetRequestHistoryMessages
    {
        [TestMethod]
        public void ThenItShouldReturnHistoryMessages()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            pubnub.history(channel, 1);
            
        }
        
        static void Pubnub_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            foreach (object history_message in ((Pubnub)sender).History)
            {
                Dictionary<string, object> _messageHistory = (Dictionary<string, object>)(history_message);
                Assert.AreEqual(_messageHistory["text"], "");
            }
        }
    }
}
