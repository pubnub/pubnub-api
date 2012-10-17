using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenAMessageIsPublished
    {
        ManualResetEvent manualEvent = new ManualResetEvent(false);
        bool publishedMessage = false;

        [TestMethod]
        public void ThenItShouldReturnSuccessCodeAndInfo()
        {
            publishedMessage = false;

            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish(channel, message,ThenDoCallback);
            manualEvent.WaitOne();
            Assert.IsTrue(publishedMessage);
        }

        public void ThenDoCallback(object result)
        {
            List<object> message = result as List<object>;

            if (message != null && message.Count >= 2)
            {
                if (message[1].ToString().Length > 1)
                {
                    publishedMessage = true;
                }
            }
            manualEvent.Set();
        }


        [TestMethod]
        public void ThenItShouldGenerateUniqueIdentifier()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );

            Assert.IsNotNull(pubnub.generateGUID());
        }

        [TestMethod]
        public void ThenPublishKeyShouldBeOverriden()
        {
            publishedMessage = false;

            Pubnub pubnub = new Pubnub(
                "",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";
            pubnub.PUBLISH_KEY = "demo";

            pubnub.publish(channel, message, ThenDoCallback);
            manualEvent.WaitOne();
            Assert.IsTrue(publishedMessage);
        }

        [TestMethod]
        public void ThenPublishKeyShouldNotBeEmptyAfterOverriden()
        {
            publishedMessage = false;

            Pubnub pubnub = new Pubnub(
                "",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish(channel, message, ThenDoCallback);
            manualEvent.WaitOne();
            Assert.IsTrue(publishedMessage);
        }

        [TestMethod]
        public void ThenSecretKeyShouldBeProvidedOptionally()
        {
            publishedMessage = false;
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo"
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish(channel, message, ThenDoCallback);
            manualEvent.WaitOne();

            publishedMessage = false;
            pubnub.SECRET_KEY = "key";

            pubnub.publish(channel, message, ThenDoCallback);
            manualEvent.WaitOne();
            Thread.Sleep(1000);
            Assert.IsTrue(publishedMessage);
        }

        [TestMethod]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            publishedMessage = false;
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                ""
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish(channel, message, ThenDoCallback);
            manualEvent.WaitOne();
            Assert.IsTrue(publishedMessage);
        }
    }
}
