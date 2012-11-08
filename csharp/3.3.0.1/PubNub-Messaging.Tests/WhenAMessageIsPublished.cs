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
    public class WhenAMessageIsPublished
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);
        ManualResetEvent manualEvent3 = new ManualResetEvent(false);

        bool isPublished1 = false;
        bool isPublished2 = false;
        bool isPublished3 = false;

        [TestMethod]
        public void ThenPublishedShouldReturnSuccessCodeAndInfo()
        {
            isPublished1 = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, ReturnSuccessCodeCallback);
            manualEvent1.WaitOne(310*1000);

            Assert.IsTrue(isPublished1, "Publish Failed");
        }

        private void ReturnSuccessCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    int statusCode = (int)receivedObj[0];
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isPublished1 = true;
                    }
                }
            }
            manualEvent1.Set();
        }


        [TestMethod]
        public void ThenPubnubShouldGenerateUniqueIdentifier()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            Assert.IsNotNull(pubnub.generateGUID());
        }

        [TestMethod]
        [ExpectedException(typeof(MissingFieldException))]
        public void ThenPublishKeyShouldNotBeEmpty()
        {
            Pubnub pubnub = new Pubnub("", "demo", "", "", false);

            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, null);
        }


        [TestMethod]
        public void ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            isPublished2 = false;
            Pubnub pubnub = new Pubnub("demo","demo","key");
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, ReturnSecretKeyPublishCallback);
            manualEvent2.WaitOne(310 * 1000);

            Assert.IsTrue(isPublished2, "Publish Failed with secret key");
        }

        private void ReturnSecretKeyPublishCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    int statusCode = (int)receivedObj[0];
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isPublished2 = true;
                    }
                }
            }
            manualEvent2.Set();
        }

        [TestMethod]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            isPublished3 = false;
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                ""
            );
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, ReturnNoSSLDefaultFalseCallback);
            manualEvent3.WaitOne(310 * 1000);
            Assert.IsTrue(isPublished3, "Publish Failed with no SSL");
        }

        private void ReturnNoSSLDefaultFalseCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    int statusCode = (int)receivedObj[0];
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isPublished3 = true;
                    }
                }
            }
            manualEvent3.Set();
        }
    }
}
