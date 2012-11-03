using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using PubnubSilverlight.Core;
using Microsoft.Silverlight.Testing;

namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenSubscribedToAChannel
    {
        ManualResetEvent manualEvent = new ManualResetEvent(false);
        bool receivedMessage = false;

        [TestMethod]
        [Asynchronous]
        public void ThenItShouldReturnReceivedMessage()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            //string channel = "my ~`!@#$%^&*()+=[]\\{}|;':\",./<>?channel";
            string channel = "my_channel";

            pubnub.subscribe(channel, ThenDoCallback);

            //manualEvent.WaitOne(10000, false); *Changed*
            Assert.IsTrue(receivedMessage);
        }

        public void ThenDoCallback(object result)
        {
            List<object> message = result as List<object>;

            if (message != null && message.Count >= 2)
            {
                if (message[1].ToString().Length > 1)
                {
                    receivedMessage = true;
                }
            }
            manualEvent.Set();
            Assert.IsTrue(receivedMessage);
        }

    }
}
