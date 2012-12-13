using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenSubscribedToAChannel
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);

        bool receivedMessage = false;

        [TestMethod]
        public void ThenSubscribeShouldReturnReceivedMessage()
        {
            receivedMessage = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);

            string channel = "my/channel";

            pubnub.subscribe<string>(channel, ReceivedMessageCallback);
            Thread.Sleep(5000);

            pubnub.publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback);
            manualEvent2.WaitOne(310 * 1000);

            manualEvent1.WaitOne(310*1000);
            Assert.IsTrue(receivedMessage,"WhenSubscribedToAChannel --> ThenItShouldReturnReceivedMessage Failed");
        }

        private void ReceivedMessageCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    object subscribedObj = (object)receivedObj[0];
                    if (subscribedObj != null)
                    {
                        receivedMessage = true;
                    }
                }
            }
            manualEvent1.Set();
        }

        private void dummyPublishCallback(string result)
        {
            manualEvent2.Set();
        }

    }
}
