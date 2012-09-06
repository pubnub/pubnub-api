using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenAMessageIsPublished
    {
        [TestMethod]
        public void ThenItShouldReturnSuccessCodeAndInfo()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            pubnub.publish(channel, message);
        }

        static void Pubnub_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            Assert.AreEqual("1", ((Pubnub)sender).Publish[0].ToString());
            Assert.AreEqual("Sent", ((Pubnub)sender).Publish[0].ToString());
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
            Pubnub pubnub = new Pubnub(
                "",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            pubnub.PUBLISH_KEY = "demo";
            Assert.AreEqual(true, pubnub.publish(channel, message));

        }

        [TestMethod]
        public void ThenPublishKeyShouldNotBeEmptyAfterOverriden()
        {
            Pubnub pubnub = new Pubnub(
                "",
                "demo",
                "",
                "",
                false
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            Assert.AreEqual(false, pubnub.publish(channel, message));
        }

        [TestMethod]
        public void ThenSecretKeyShouldBeProvidedOptionally()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo"
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            Assert.AreEqual(true, pubnub.publish(channel, message));

            pubnub.SECRET_KEY = "key";
            Assert.AreEqual(true, pubnub.publish(channel, message));
        }

        [TestMethod]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                ""
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            Assert.AreEqual(true, pubnub.publish(channel, message));
        }
    }
}
