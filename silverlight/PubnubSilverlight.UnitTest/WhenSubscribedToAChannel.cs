using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;
using PubnubSilverlight.Core;
using Microsoft.Silverlight.Testing;

namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenSubscribedToAChannel : SilverlightTest
    {
        bool isReceived = false;
        bool isPublished = false;

        bool receivedMessage = false;

        [TestMethod]
        [Asynchronous]
        public void ThenSubscribeShouldReturnReceivedMessage()
        {
            receivedMessage = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);

            string channel = "test";

            EnqueueCallback(() => pubnub.subscribe<string>(channel, ReceivedMessageCallback));
            EnqueueCallback(() => pubnub.publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback));
            EnqueueConditional(() => isPublished);
            EnqueueConditional(() => isReceived);
            EnqueueCallback(() => Assert.IsTrue(receivedMessage, "WhenSubscribedToAChannel --> ThenItShouldReturnReceivedMessage Failed"));

            EnqueueTestComplete();
        }

        [Asynchronous]
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
            isReceived = true;
        }

        [Asynchronous]
        private void dummyPublishCallback(string result)
        {
            isPublished = true;
        }

    }
}
