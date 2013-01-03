using System;
using PubNub_Messaging;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;


namespace PubNubTest
{
    [TestFixture]
    public class WhenAMessageIsPublished
    {
        public void NullMessage()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";
            string message = null;

            Common cm = new Common();
            cm.deliveryStatus = false;
            cm.objResponse = null;

            pubnub.publish(channel, message, cm.DisplayReturnMessage);
            //wait till the response is received from the server
            while (!cm.deliveryStatus) ;
            IList<object> fields = cm.objResponse as IList<object>;
            string strSent = fields[1].ToString();
            string strOne = fields[0].ToString();
            Assert.True(("Sent").Equals(strSent));
            Assert.True(("1").Equals(strOne));
        }

        [Test]
        public void ThenItShouldReturnSuccessCodeAndInfo()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";
            string message = "Pubnub API Usage Example";

            Common cm = new Common();
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenAMessageIsPublished";
			unitTest.TestCaseName = "ThenItShouldReturnSuccessCodeAndInfo";
			
			pubnub.PubnubUnitTest = unitTest;
            cm.deliveryStatus = false;
            cm.objResponse = null;

            pubnub.publish(channel, message, cm.DisplayReturnMessage);
            //wait till the response is received from the server
            while (!cm.deliveryStatus) ;
            IList<object> fields = cm.objResponse as IList<object>;
            string strSent = fields[1].ToString();
            string strOne = fields[0].ToString();
            Assert.True(("Sent").Equals(strSent));
            Assert.True(("1").Equals(strOne));
        }

        [Test]
        public void ThenItShouldGenerateUniqueIdentifier()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );

            Assert.NotNull(pubnub.generateGUID());
        }

        [Test]
        public void ThenPublishKeyShouldBeOverriden()
        {
            Pubnub pubnub = new Pubnub(
                "",
                "demo",
                "",
                "",
                false
            );
            string channel = "mychannel";
            string message = "Pubnub API Usage Example";

            pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            Common cm = new Common();
            Assert.True((true).Equals(pubnub.publish(channel, message, cm.DisplayReturnMessage)));
        }

        [Test]
        [ExpectedException(typeof(MissingFieldException))]
        public void ThenPublishKeyShouldNotBeEmptyAfterOverriden()
        {
            Pubnub pubnub = new Pubnub(
                "",
                "demo",
                "",
                "",
                false
            );
            string channel = "mychannel";
            string message = "Pubnub API Usage Example";
            Common cm = new Common();
            Assert.True((false).Equals(pubnub.publish(channel, message, cm.DisplayReturnMessage)));
        }

        [Test]
        public void ThenSecretKeyShouldBeProvidedOptionally()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo"
            );
            string channel = "mychannel";
            string message = "Pubnub API Usage Example";
            Common cm = new Common();
            Assert.True((true).Equals(pubnub.publish(channel, message, cm.DisplayReturnMessage)));
            pubnub = new Pubnub(
                "demo",
                "demo",
                "key"
            );
			Assert.True((true).Equals(pubnub.publish(channel, message, cm.DisplayReturnMessage)));
        }

        [Test]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                ""
            );
            string channel = "hello_world";
            string message = "Pubnub API Usage Example";
            Common cm = new Common();
			Assert.True((true).Equals(pubnub.publish(channel, message, cm.DisplayReturnMessage)));
        }

        [Test]
        [ExpectedException(typeof(MissingFieldException))]
        public void NullShouldBeTreatedAsEmpty()
        {
            Pubnub pubnub = new Pubnub(
                null,
                "demo",
                null,
                null,
                false
            );
            string channel = "mychannel";
            string message = "Pubnub API Usage Example";
            Common cm = new Common();
			Assert.True((false).Equals(pubnub.publish(channel, message, cm.DisplayReturnMessage)));
        }
    }
}

